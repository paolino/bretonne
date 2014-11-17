(
s.boot;
Server.local.options.maxNodes(10000);
s.options.memSize=40000;
//FreqScope();
m = {Bus.control()}!16;
c =  Array.fill(8,{arg i;CCResponder({|s,ch,c,v| m[i].set(v/128)},nil,1,i+21)}) ++
Array.fill(8,{arg i;CCResponder({|s,ch,c,v| m[i+8].set(v/128)},nil,1,i+41)});
)


// recording
(
var file = "clip.wav";
s.recHeaderFormat="wav";
s.recSampleFormat="int32";
s.record(file);
)
s.stopRecording;

(
var notes, on, off;

MIDIClient.init;
MIDIIn.connectAll;

notes = Array.newClear(128);    // array has one slot per possible MIDI note

on = MIDIFunc.noteOn({ |veloc, num, chan, src|
    notes[num] = Synth(\pmosc16, [\freq, num.midicps,
        \amp, veloc/128,\gate,1]);
});

off = MIDIFunc.noteOff({ |veloc, num, chan, src|
	notes[num].set(\gate,0);
});

q = { on.free; off.free; };
)

// when done:
q.value;
// phase modulation
(
SynthDef(\pmosc16,{ |freq, amp,gate=1|
	var delta = 0.01;
	var siga,del1=0.1;
	var tapPhase,tap1,tap2,tap3;
	var dur = In.kr(m[3])*3;
	var dev = {rrand(0.99,1.01)}!8;
	var env = EnvGen.ar(Env.asr(0.01,amp,In.kr(m[13]),0),gate,doneAction:2);
	var sig = VarSaw.ar(freq*dev,0,(In.kr(m[1])), 3, mul: 1)*env;

	siga=AllpassL.ar(sig,0.2,
		SinOsc.kr(
			In.kr(m[10])*3,0,
			In.kr(m[8])*(In.kr(m[9])/10),
			In.kr(m[9])/10),1);
    sig = RLPF.ar(sig+ (In.kr([12])*siga), In.kr(m[2])*1000,In.kr(m[4]));
	//del1=SinOsc.kr(In.kr(m[10])*10,0,In.kr(m[8]);

	sig = Pan2.ar(Mix.ar(sig));
	Out.ar(0,In.kr(m[15])*sig * amp)
}).add;
)
(
SynthDef(\violin,{ |freq, amp|
	var delta = 0.01;
	var siga;
	var tapPhase,tap1,tap2,tap3;
	var dur = In.kr(m[3])*3;
	var f1 = {rrand(1-delta,1+delta)}!16;
	var f2 = {rrand(1-delta,1+delta)}!16;
	var env = EnvGen.ar(Env.perc(0.1,dur),doneAction:2);
	var sig = Saw.ar([freq,freq*2]);
	sig = RLPF.ar(sig, In.kr(m[2])*400,In.kr(m[4]));
	sig= Klank.ar(`[[300, 350, 1000], nil, [1, 1, 1, 1]], sig);
	sig = RHPF.ar(sig, (In.kr(m[6])*400),In.kr(m[7]));

	sig = Pan2.ar(Mix.ar(Normalizer.ar(sig)));
	Out.ar(0,In.kr(m[15])*sig * amp*1*env)
}).add;
)

{SinOsc.ar(500, mul: SinOsc.ar(250, mul: 0.5))}.scope(1)
(
 {1*Mix.ar
	(Saw.ar
		(200*(1), mul: Saw.ar
			(50*(1), mul: 0.5)))!2
}.scope(1)
)
16.do({arg i; get(m[i]).postln});,

	rrand(23,24)
