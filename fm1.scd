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
c = NoteOnResponder({ |src,chan,note,vel| Synth(\pmosc16,[\freq,note.midicps,\amp,vel/128])})
)
(
c = NoteOnResponder({ |src,chan,note,vel| [chan,note,vel].postln})
)

// recording
(
var file = "fm3.wav"
s.recHeaderFormat="wav";
s.recSampleFormat="int32";
s.record(file);
)
s.stopRecording;

// phase modulation
(
SynthDef(\pmosc16,{ |freq, amp|
	var delta = 0.03;
	var dur = In.kr(m[3])*3;
	var f1 = {rrand(1-delta,1+delta)}!16;
	var f2 = {rrand(1-delta,1+delta)}!16;
	var env = EnvGen.ar(Env.perc(0.0001,dur),doneAction:2);
	var sig = PMOsc.ar((3*In.kr(m[0]) + freq)*f1,(3*In.kr(m[1]) + freq) * f2, 3, mul: 0.5);
	sig = Pan2.ar(Mix.ar(sig));
	Out.ar(0,sig * amp*0.1*env)
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
