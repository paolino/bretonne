s.boot;
FreqScope();
FreqScopeView();

// map controller
(
m = {Bus.control()}!16;
c =  Array.fill(8,{arg i;CCResponder({|s,ch,c,v| m[i].set(v/128)},nil,1,i+21)}) ++
Array.fill(8,{arg i;CCResponder({|s,ch,c,v| m[i+8].set(v/128)},nil,1,i+41)})
)

// map notes


(
c = NoteOnResponder({ |src,chan,note,vel| Synth(\violin,[\freq,note.midicps,\amp,vel/128])})
)
(
c = NoteOnResponder({ |src,chan,note,vel| [chan,note,vel].postln})
)

// recording
(
var file = "fr.wav";
s.recHeaderFormat="wav";
s.recSampleFormat="int32";
s.record(file);
)
s.stopRecording;
b = Buffer.alloc(s, s.sampleRate * 1, 1);
// phase modulation
(
a = Pseq([Pseq([60, 60,72,48],3),[51,49,49,48]] - 12, inf).asStream;
Routine({
    loop({
        Synth(\pmosc16, [\freq, a.next.midicps,\amp,0.5]);,
    })
}).play(quant:4);
)

p = Pbind(\instrument, \pmosc16, \freq, 440, \pan, -1, \delta, 1.0, \sustain, 0.1,\amp,0.3).play(quant: [2, 0, 0]);

q = Pbind(\instrument, \pmosc16, \freq, 340, \pan, -1, \delta, 1.0, \sustain, 0.1,\amp,0.2).play(quant: [3, 0.25, 0]);
q.stop
(
b = Pseq([46] - 12, inf).asStream;
Routine({
    loop({
        Synth(\pmosc16, [\freq, b.next.midicps,\amp,0.5]);
        0.15.wait;
    })
}).play(quant:4);
)
a.stop
(
SynthDef(\pmosc16,{ |freq, amp|
	var delta = 0.01;
	var siga;
	var tapPhase,tap1,tap2,tap3;
	var dur = In.kr(m[3])*3;
	var att = In.kr(m[14])*0.1;
	var f1 = {rrand(1-delta,1+delta)}!16;
	var f2 = {rrand(1-delta,1+delta)}!16;
	var env = EnvGen.ar(Env.perc(att,dur),doneAction:2);
	var sig = PMOsc.ar((3*In.kr(m[0]) + (freq/2))*f1,(3*In.kr(m[1]) + (freq/2)) * f2, 3, mul: 0.5);
	sig = RLPF.ar(sig, In.kr(m[2])*400,In.kr(m[4]));
	siga = DelayL.ar(sig,0.1,In.kr(m[8]).poll*0.01);
	sig = sig + (In.kr([9])*siga);
	sig = Pan2.ar(Mix.ar(Normalizer.ar(sig)));
	Out.ar(0,In.kr(m[15])*sig * amp*0.1*env)
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
16.do({arg i; get(m[i]).postln});

	rrand(23,24)
