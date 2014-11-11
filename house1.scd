(
Server.local.reboot;
MIDIIn.connect(0,3);
MIDIIn.connect(0,4);
~mo = MIDIOut(0).connect(2); //feedback for channel 1
~mo.latency = 0;
)

(
~piece = "fr23";
~name = "/home/paolino/mysounds";
~buffers = ( ~name ++"/*.wav").pathMatch.collect({ arg i;  Buffer.read(s, i)});

~ntracks = 18;
~ncontrols = 57;

~controls = {Bus.control()}!(~ncontrols*~ntracks);
~controlled = 0; // actual controlled track
~lps = 125/15; //bpm
~ping = Bus.control(); // main beat
~reset = {Bus.control()}!7; //bars resetting

// load the file or set all param to 0 for all parameter sets
File.exists(~piece ++ ".data").if(
	{~store = Object.readArchive(~piece ++ ".data")},
	{~store = Array.fill(16,{|i| Array.fill(~ntracks * ~ncontrols,{0})})}
);
~istore = 0;
// initialize the story
~controls[0].setnSynchronous(~store[~istore]);

// actual parameter set

// track switcher
~setsynth = {|n|
	~controlled = n; // set the track number
	// give feedback to total recall unit bcr2000
	(~controls[(~controlled * ~ncontrols)].getnSynchronous(~ncontrols)).do({|v,c| ~mo.control(1,c,v*128)});
};
//initialize console
~setsynth.value(~controlled);
// parameter set switcher
~setstore = {|v|
	v.postln;
	~store[~istore] = ~controls[0].getnSynchronous(~ntracks*~ncontrols);
	~istore = v;
	~controls[0].setnSynchronous(~store[~istore]);
	~setsynth.value(~controlled);
	~store.writeArchive(~piece ++ ".data");
};

CCResponder.removeAll;
CCResponder({|s,ch,c,v| ~setstore.value(v%16)},nil,1,58); //1 + 58 + i set the store index to i
CCResponder({|s,ch,c,v| ~controls[56 + (c * ~ncontrols)].set(v/128)},nil,0); //volumes on channel 0
CCResponder({|s,ch,c,v| ~controls[(c % 56) + (~controlled * ~ncontrols)].set(v/128)},nil,1,{|c| c < 56}); //controls on 1
CCResponder({|s,ch,c,v| ~setsynth.value(v%~ntracks);"pippo".postln},nil,1,57); //switch track on ch 1 par 57

)


(
var size =1024;
var sinlf;
var ph;

sinlf = Buffer.alloc(s, size, 1,
	completionMessage: { |buf| buf.sine3Msg(#[1],[1],[pi/2], asWavetable: false);});

~rsinosc = {|t_reset = 0, freq = 1, phase = 0, amp = 1, add = 0|
	ph = Phasor.kr(t_reset, freq / ControlRate.ir, 0.0, 1.0);
	BufRd.kr(1, sinlf, size * (ph + phase), interpolation: 1) * amp + add;
    };

~sound = {|n|

	var start,sig,env;
	var freqs,delayed,delay;
	var freqs2,rythms2;
	var controls,rythms,bufnum;
	var loop,instn = n * ~ncontrols;

	controls = {|n| Lag.kr(In.kr(~controls[n + instn]),0.1)};

	loop = In.kr(Select.kr(controls.value(23)*8,~reset));

	freqs = ~lps/16*LinExp.kr(controls.value([0,1,2]),0,1,1,8);

	rythms = Mix.kr(~rsinosc.value(loop
			, freqs
			,controls.value([8,9,10])*(1/freqs)
			,controls.value([16,17,~ntracks])
	));
	rythms = Select.kr(controls.value(6)*4,[
		rythms.squared,
		rythms.squared.squared,
		rythms.squared.squared.squared,
		rythms.squared.squared.squared.squared]);
	freqs2 = ~lps/8*(1 + (7*controls.value([3,4])));
	rythms2 = Mix.kr(
			~rsinosc.value(loop
			, freqs2
			,controls.value([11,12])
			,controls.value([19,20])
			).squared
			)/50;

	bufnum = Select.kr(controls.value(7)*~buffers.size,~buffers);
	start = Clip.kr((controls.value(22)  - 0.5 +(1 - rythms)),0,1) * BufFrames.kr(bufnum);
	delayed = DelayC.kr(In.kr(~ping),1,rythms2);
	env = EnvGen.ar(Env.linen(0.01,0.9*15/125-0.03,0.01),delayed);
	sig =   PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum)*(0.5 + controls.value(21)), delayed, start , 0);
	sig = FreeVerb.ar(sig,controls.value(24),controls.value(25),controls.value(26));
	sig = RLPF.ar(sig,LinExp.kr(1 - controls.value(27),0,1,20,20000),(1 - controls.value(28)));
	sig = RHPF.ar(sig,LinExp.kr(controls.value(29),0,1,20,20000),(1 - controls.value(30)));
	env  *  controls.value(56) * sig;
};

//line impulse
~pinger.free;
~pinger = {Out.kr(~ping,Impulse.kr(~lps))}.play;

// bars impulse
~bars.free;
~bars = {Out.kr(~reset[0],Impulse.kr(~lps/[8,16,32,64,128,256]))}.play;

~round =1;
~jump.free;
~jump = {SendTrig.kr(Impulse.kr(~lps/16),0,0)}.play;

// o = OSCFunc({ arg msg, time;
// 	[time, msg].postln;
// 	~round = ~round;
// 	~setstore.value(~round % 2);
// },'/tr', s.addr);
// sounds
~synths.do({|i| i.free;});
~synths = ~ntracks.collect ({|i| {~sound.value(i)}.play});
)
(
var file = "fr23.wav";
s.recHeaderFormat="wav";
s.recSampleFormat="int32";
s.record(file);
)
s.stopRecording;0
