s.boot;


(
m = {Bus.control()}!128;
c =  CCResponder({|s,ch,c,v| [s,ch,c,v].postln;m[c].set(v/128)},nil,0);
~lm = {|n| Lag.kr(In.kr(m[n]),0.1)}
)
CCResponder.removeAll;

(
c = NoteOnResponder({ |src,chan,note,vel| Synth(\violin,[\freq,note.midicps,\amp,vel/128])})
)

(
SynthDef(\sine,{ |base,out|
	var bank;
	bank=Mix.fill(3,
		{arg i;
			var base2 = base * ( i + 1);
			var s1 = SinOsc.kr(4*base2,mul:pi * ~lm.value(i * 6 ));
			var s2 = SinOsc.kr(3*base2,mul:pi * ~lm.value(i * 6 +1));

			var s3 = SinOsc.kr(2*base2,mul:pi * ~lm.value(i * 6 + 2));
			SinOsc.kr(base2 , s2 + s1 + s3 ,mul:~lm.value(i * 6 + 3))}
	);
	Out.kr(out, bank.abs);
}).send
)
(

b = Bus.control();
~pro = Synth(\sine,[\base,0.5,\out,b]);



q = {Pan2.ar(Mix.ar(VarSaw.ar(0.5*{rrand(99.85, 100)}!8,0,0.45,In.kr(b)/2)))}.play
)
q.free

