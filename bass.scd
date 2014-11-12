
(

~controls = {Bus.control()}!16;

CCResponder.removeAll;
8.do({|i|	CCResponder({|s,ch,c,v| ~controls[i].set(v/128).postln},nil,1,21+i)});
8.do({|i|	CCResponder({|s,ch,c,v| ~controls[8+ i].set(v/128).postln},nil,1,41+i)});

~c = { |n| Lag.kr(In.kr(~controls[n]))};
)
(
{   var env = EnvGen.ar(Env.perc,Impulse.ar((2*SinOsc.kr(4,0,2,2).abs).floor),1,0,0.1 + LFSaw.kr((~c.value(8)*8).floor,~c.value(9)).squared);
	var sig = VarSaw.ar({rrand(0.99,1.01)}!8 * 80 ,0,~c.value(0) + {LFNoise2.ar(1,0.1)}!4,~c.value(1))*0.1;
	sig = RLPF.ar(sig,~c.value(2)*1000,~c.value(3));
	sig * env
}.play
)
(
d = SynthDef("help-MostChange", { arg amp=1.0;
    var out, in1, in2;
    in1 = LFNoise1.ar(100, amp);
    in2 = SinOsc.ar(100);
    out = MostChange.ar(in1, in2) * 0.1;
    Out.ar(0, out)
}).play;
)
d.set(\amp,0);
(
{ Integrator.ar(LFPulse.ar(300, 0.2, 0.1), MouseX.kr(0.001, 0.999, 1)) }.play
{ Lag.kr(InRange.kr(SinOsc.kr(1, 0, 0.2)*SinOsc.kr(2.5), ~c.value(0), ~c.value(1))) * SinOsc.ar(80)}.scope;
)

(// trigger noise Burst(ù
{   var trig = Schmidt.kr(SinOsc.kr(2,~c.value(11)*pi) + SinOsc.kr(4,~c.value(12)*pi) , ~c.value(6), ~c.value(7)) + Schmidt.kr(SinOsc.kr(2,~c.value(11)*pi) + SinOsc.kr(4,~c.value(12)*pi) , ~c.value(4), ~c.value(5));

	var env = EnvGen.ar(Env.adsr(0.01,~c.value(8)),trig);
    var sig;
	sig = 0.2*Wrap.ar(SinOsc.ar([64,64.01], 0, 0.9), ~c.value(0)-1,~c.value(1));
	//sig = VarSaw.ar({rrand(0.99,1.01)}!8 * 80 * (1 + (env/100)) ,0,~c.value(0),~c.value(1))*0.1;
	sig = RLPF.ar(sig,(1 - env) *500*~c.value(2) + 500,(0.2 + (env/2)));
	sig * env
}.play
)
{ Wrap.ar(SinOsc.ar([64,64.01], 0, 0.9), ~c.value(0)-1,~c.value(1)) }.scope;
{LFSaw.kr(0.5,~c.value(8))+LFSaw.kr(1,~c.value(9))+LFSaw.kr(2,~c.value(10)) + LFSaw.kr(4,~c.value(11)) /4}.scope

FreqScope()
(
{
    var a, freq, trig;
    a = Dseries(0, 1, inf);
    trig = Impulse.kr(MouseX.kr(1, 40, 1));
    freq = Demand.kr(trig, 0, a) % 15 * 30 + 340;
    SinOsc.ar(freq) * 0.1

}.play;
)
(
{
    var a, freq, trig;
    a = Dgeom(1, 1.2, inf);
    trig = Dust.kr(MouseX.kr(1, 40, 1));
    freq = Demand.kr(trig, 0, a) * 30 + 340;
    SinOsc.ar(freq) * 0.1

}.play;
)



(
    {
        var freq;
        freq = Duty.kr(
                Dseq([0.2, 0.2, 0.4,0.2,0.1,0.1,0.4], inf), // demand ugen as durations
                0,
                Dseq([201,]/3, inf)
            );
        VarSaw.ar(freq * [1, 1.01]) * 0.1

    }.play;
)


