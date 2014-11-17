(
~seq = {
	arg k,m,ro,l,j,h;
	var n=0,p=0,ls=Array.fill(l,{false});
	var r = k.collect({|i|
		if(ls[n%l]==true ,{p = (p + 1)%ro.size},{ls[n%l]=true});
		n = (n + ro[p]);
		[Scale.spanish.degreeToFreq((i*h%(j*h)+m),80,0),n%l]
	});

r
}
)

Scale.directory
[[1,2],[3,4]].flatten(1)

{ TDuty.ar(Dseq(~l.collect({|i| i[1]})/4, inf))}.play; // demand ugen as durations
~l;
(~l.collect({|i| i[1]})/4
// allocate a Buffer
s = Server.local;

)

// record for four seconds
(
SynthDef(\help_RecordBuf, { arg out = 0;
    var formant;
    formant = Formant.ar(XLine.kr(400,1000, 1), 2000, 800, 0.125);
    RecordBuf.ar(formant, b, doneAction: 2, loop: 0);
}).play(s,[\out, 0, \bufnum, b]);
)
(
SynthDef(\help_RecordBuf_overdub, { arg out = 0, bufnum = 0;
    var playbuf;
    playbuf = PlayBuf.ar(1,bufnum,loop:1);
    FreeSelfWhenDone.kr(playbuf); // frees the synth when the PlayBuf is finished
	Out.ar(out, 0.2  * {playbuf}!2);
}).play(s, [\out, 0, \bufnum, b]);
)
~l
~l.collect({|i| i[1]})/4;
~l  = ~seq.value(4,1,[4,7,5]);
~l.sum({|t| t[1]})
~l

Array.fill(11,{|i| 1/(10 + i).sqrt.sqrt}) ++[0]


(
SynthDef(name:\punch,ugenGraphFunc:
	{   |bufnum,freq,amp,where|


		var sig = RLPF.ar(VarSaw.ar(freq*{rrand(0.99,1.01)}!1,0,width:0.05),1000);
		var env = EnvGen.ar(envelope:Env.perc(0.0001,0.5,1,curve:-2),doneAction:2);
		sig = Mix.ar(sig*env);
		RecordBuf.ar(DelayL.ar(sig,0.1,0.009),bufnum,offset:where,recLevel:1,preLevel:1,loop:1)
		//Out.ar(0,sig*env*amp);

}).send

);
{Out.ar(0, 0.2  * ({PlayBuf.ar(1,b,loop:1)}!2))}.play
b.zero;
(
b.zero;
~l  = ~seq.value(30,6,[5,13,7],16,5,2);
~l.do({|lo| Synth(\punch,[
	\bufnum,b,
	\freq,lo[0],
	\amp,1,
	\where,
	lo[1]/16*b.numFrames*b.numChannels])})
)
Synth(\punch,[\bufnum,b,\freq,100,\amp,1,\where,0])
~l

}
		var amps = Array.fill(11,{|i| 1/(2*i + 1).sqrt.sqrt}) ++[0]));
		var freqs = lo[0];
		var durs  = lo[1]/vel;



b = Buffer.alloc(s, Server.local.sampleRate * 2.0, 1,183); // a four second 1 channel Buffer
b.zero;
(
b.zero;

~l  = ~seq.value(30,-2,[9,14,5],16,4,2);
SynthDef(name:\loop,ugenGraphFunc:
	{   |vel = 8,curve = -2,attack=0.0001|
	var ts = (~l.collect({|i| i[1]}))/vel;
	var fs = (~l.collect({|i| i[0]}))/1;

		var l = TDuty.ar(Dseq(ts ++ [1]),0,1,2);
		var lo = Demand.ar(l,0,Dseq(~l));

		var amps = Demand.ar(l,0,Dseq(Array.fill(11,{|i| 1/(2*i + 1).sqrt.sqrt}) ++[0]));
	var freqs = lo[0];
	var durs  = lo[1]/vel;

		var sig = RLPF.ar(LFSaw.ar(Lag.ar(freqs)*{rrand(0.99,1.01)}!5,0,0.5),400);
		var env = EnvGen.ar(Env.perc(0.01,0.25,1,curve),l);
		sig = Mix.ar(env*sig*amps);
	//DetectSilence.ar(sig,0.0000001, );
	    RecordBuf.ar(sig,b,0,1,1);
		//Out.ar(0,sig);
}).play;
)

(
SynthDef(name:\loop,ugenGraphFunc:
	{   |vel = 8,curve = -2,attack=0.0001|
	var ts = (~l.collect({|i| i[1]}))/vel;
	var fs = (~l.collect({|i| i[0]}))/1;
		var l = TDuty.ar(Dseq(ts),0,1,2);
		var lo = Demand.ar(l,0,Dseq(~l));


	var freqs = lo[0];
	var durs  = lo[1]/vel;

		var sig = LFPar.ar(freqs*{rrand(0.99,1.01)}!5,0,0.5);
	var env = EnvGen.ar(Env.perc(0.01,durs,1,curve),l);
	sig = Mix.ar(env*sig)*0.2;
	//DetectSilence.ar(sig,0.0000001, );
	RecordBuf.ar(0,b,0,1,1);
	0
}).play;
)
;

x = Synth(\loop);
1
x.set(\curve,-8);
x
~l
{~synth.value(l)}.play;
(
SynthDef(\help_sinegrain,
    { arg out=0, freq=440, sustain=0.05;
        var env;
        env = 0.2*EnvGen.kr(Env.perc(0.01, 0.2), doneAction:2);
        Out.ar(out, SinOsc.ar(freq, 0, env))
    }).add;
)
(
a = Pseq(l.collect({|i| i[0][0]}), inf).asStream;
a.next;
)

(
a = Pseq(l.collect({|i| i[0][0]}), inf).asStream;

Routine({
    loop({
		Synth(\help_sinegrain, [\freq, a]);
		a.next;
        0.2.wait;
    })
}).play;
)