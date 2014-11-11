s.boot;
~piece = "fr14";
// saver
(
~controls[0].getnSynchronous(18*~ncontrols).writeArchive(~piece ++ ".data");
)
//reader
(
~controls[0].setnSynchronous(Object.readArchive(~piece ++ ".data"));
)
(
var size = 1024;
var sinlf;
var ph;

sinlf = Buffer.alloc(s, size, 1, completionMessage: { |buf| buf.sine3Msg(#[1],[1],[pi/2], asWavetable: false);});
//resettable sine lfo
~rsinosc = {|t_reset = 0, freq = 1, phase = 0, amp = 1, add = 0|
	//

ph = Phasor.kr(t_reset, freq / ControlRate.ir, 0.0, 1.0);
	BufRd.kr(1, sinlf, size * (ph + phase), interpolation: 1) * amp + add;
};

~name = "/home/paolino/mysounds";
~buffers = ( ~name ++"/*.wav").pathMatch.collect({ arg i;  Buffer.read(s, i)});
~monobuffers = ( ~name ++"/*.wav").pathMatch.collect({ arg i;Buffer.readChannel(s, i,channels:[0])});

~ncontrols=57;
~controls = {Bus.control()}!(~ncontrols*18);
~instcount = 0;
~lps = 125/15;
~ping = Bus.control(); // main beat
~reset = {Bus.control()}!7;

CCResponder.removeAll;
CCResponder({|s,ch,c,v| ~controls[56 + (c * ~ncontrols)].set(v/128)},nil,0);
CCResponder({|s,ch,c,v| ~controls[c + (~instcount * ~ncontrols)].set(v/128)},nil,1);
~mo = MIDIOut(0);
~mo.latency = 0;
~setsynth = {|n|
	~instcount = n;
	(~controls[(~instcount * ~ncontrols)].getnSynchronous(~ncontrols)).do({|v,c| ~mo.control(1,c,v*128)});
};
CCResponder({|s,ch,c,v| ~setsynth.value(v%18)},nil,2,56);
)


(
~record = {|n|

	var start,sig,gsig,env,genv;
	var cgrains,igrains,durgrains,grains,envgrains;
	var freqs,delayed,delay;
	var freqs2,rythms2;
	var midi,controls,rythms;
	var bufnum,bufnumm;
	var loop;
	var instn;
	var rev;
	instn = n * ~ncontrols;




	controls = {|n| Lag.kr(In.kr(~controls[n + instn]),0.1)};


	loop = In.kr(Select.kr(controls.value(23)*8,~reset));

	freqs = ~lps/8*(1 + (7*controls.value([0,1,2])));

	rythms = Mix.kr(~rsinosc.value(loop
			, freqs
			,controls.value([8,9,10])*(1/freqs)
			,controls.value([16,17,18])
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
	sig =   PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum)*(0.5 + controls.value(21)), delayed, start , 0);
	env = EnvGen.ar(Env.linen(0.01,0.9*15/125-0.03,0.01),delayed);
	rev = FreeVerb.ar(sig,controls.value(24),controls.value(25),controls.value(26));
	rev = RLPF.ar(rev,LinExp.kr(1 - controls.value(27),0,1,20,20000),(1 - controls.value(28)));
	rev = RHPF.ar(rev,LinExp.kr(controls.value(29),0,1,20,20000),(1 - controls.value(30)));
	sig = env  *  controls.value(56) * rev;


};
~pinger.free;
~pinger = {Out.kr(~ping,Impulse.kr(~lps))}.play;
~bars.free;
~bars = {Out.kr(~reset[0],Impulse.kr(~lps/[8,16,32,64,128,256]))}.play;
~synths.do({|i| i.free;});
~synths = 18.collect ({|i| {~record.value(i)}.play});
)

