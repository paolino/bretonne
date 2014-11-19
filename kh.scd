//global setup
s.boot;
(
~bpm=125;
~linedur = 15/~bpm;
~ninstr = 8;
~ncontrols=56;

~controls = {Bus.control()}!(~ncontrols * ~ninstr);
CCResponder({|s,ch,c,v| ~controls[c].set(v/128)},nil,1,{|c| c < 56});

~control = {|instn,n| Lag.kr(In.kr(~controls[n + (instn * ~ncontrols)]),0.1)};
~linedelay = {|c,sig| DelayL.ar(sig,2*~linedur,~linedur*(1 + (0.1*c)))};

~ping = Bus.control();
~reset = Bus.control();

~mixer = Bus.audio(s,2);

~record = Buffer.alloc(s, Server.local.sampleRate * 16 * ~linedur, 2,18);

SynthDef(\recorder,{
	var trig = DelayL.kr(In.kr(~reset),2*~linedur,~linedur);
	var env = EnvGen.ar(Env.linen(0.001,16*~linedur-0.003,0.001),trig);
	RecordBuf.ar(env*In.ar(~mixer,2),~record,run:SetResetFF.kr(trig),loop:0,doneAction:2)
	}).send;

~mainout.free;
~mainout = {Out.ar(0,In.ar(~mixer,2))}.play(addAction:\addToTail);


~directory = "bretonne/clips";
~clipname = "tunz";
~version = 1;
)
~mainout = {Out.ar(0,In.ar(~mixer,2))}.play(addAction:\addToTail);

~mixer.scope()
//clip recording
(
var name = ~directory ++ "/" ++ ~clipname ++ ~version ++ ".wav";

fork {
	Synth.tail(nil,\recorder);
	(32*~linedur).wait;
	~record.write(name,"WAV");
	(name ++ " written").postln
};
~version = ~version + 1;
)
(
SynthDef(\kick,{
    var env2,sig,env,noise,envnoise;
	var tsig = Stepper.kr(In.kr(~ping),In.kr(~reset),0,3,1,1);
	var getl = {|n| ~control.value(0,n)};
	var timses = {|n| Sweep.kr(tsig,0.1 + (5/getl.value(n).linexp(0,1,1,20)) )};
	env2 = getl.value(9) *(0.2 + IEnvGen.ar(Env.perc(0.0,2,curve:-4),timses.value(1)));
	env = getl.value(8) * IEnvGen.kr(Env.perc(0.03,2,curve:-4),timses.value(0));
	sig = SinOsc.ar(1.5*env2*(getl.value(3).linexp(0,1,40,300)) , 0)*(env);
	sig = Mix.ar(sig);
	sig = ~linedelay.value(getl.value(16),sig);
	Out.ar(~mixer,Pan2.ar(sig));

}).send;

)

(
SynthDef(\zz,{|w,a|
    var env2,sig,env,noise,envnoise,del,del2,del3,del4;
	var tsig = Stepper.kr(In.kr(~ping),In.kr(~reset),0,3,1,(w%2) * 2 + 1);
	var getl = {|n| ~control.value(0,n)};
	var timses = {|n| Sweep.kr(tsig,0.1 + getl.value(n).linexp(0,1,1,20))};

	sig= WhiteNoise.ar();
	env = getl.value(15) * IEnvGen.kr(Env.perc(0,0.4,curve:-3),timses.value(7));
	sig = RHPF.ar(sig*env,getl.value(23).linexp(0,1,3000,20000));
	sig = ~linedelay.value(getl.value(22),sig);
	Out.ar(~mixer,Pan2.ar(a*sig));
}).send;

)
(
SynthDef(\snare,{
    var env2,sig,env,noise,envnoise,sines,envsines,tri,envtri;
	var tsig = Stepper.kr(In.kr(~ping),In.kr(~reset),0,7,1,5);
	var getl = {|n| ~control.value(0,n)};
	var timses = {|n| Sweep.kr(tsig,0.1 + (10/getl.value(n).linexp(0,1,1,7)) )};
	noise = LFTri.ar(20,0,0.4,0.8) * LPF.ar(WhiteNoise.ar(),getl.value(13).linexp(0,1,300,20000));
	sines = Mix.ar(SinOsc.ar([180,330]))/2;
	tri = Mix.ar(FreqShift.ar(LFTri.ar(111) ,[175,224] + (50* getl.value(11))))/2;
	envsines = getl.value(18) * IEnvGen.kr(Env.perc,timses.value(20));
	envtri = getl.value(19) * IEnvGen.kr(Env.perc,timses.value(21));
	envnoise = getl.value(12) * IEnvGen.kr(Env.perc,timses.value(14));

	sig = ((envsines*sines)+(envtri * tri)+(noise*envnoise));

	sig = ~linedelay.value(getl.value(17),sig);
	Out.ar(~mixer,Pan2.ar(sig));

}).send;
)
(
~sn.free;
~sn = Synth(\snare);

)

(

)
//heart beat
(
~pinger.free;
~pinger = {Out.kr(~ping,Impulse.kr(1/~linedur))}.play;
~resetter.free;
~resetter= {DelayL.kr(Out.kr(~reset,PulseDivider.kr(In.kr(~ping),16)),0.1,0.05)}.play
)

(
~kick.free;
~kick = Synth(\kick);
~h1.free;
~h1 = Synth(\zz,[\w,1,\a,1]);
~h2.free;
~h2 = Synth(\zz,[\w,0,\a,0.03]);
~sn.free;
~sn = Synth(\snare);

)
(
{
	var trig = In.kr(~ping);
	var ktrig = PulseDivider.kr(trig,2,0);
	var env = EnvGen.ar(Env.perc(0.01,1.2,curve:-5),ktrig);
	var env2 = EnvGen.ar(Env.perc(0.001,1.2,curve:-5),ktrig);
	sig =
	Out.ar(0,{DelayL.ar(0.1*SinOsc.ar(In.kr(~controls[0])*120*env2,0,env),0.1 * In.kr(~controls[8]))}!2);

	Out.ar(0,{In.kr(~controls[1])*hiha}!2);

}.play
)

({
	var trig = In.kr(~ping);
	var ktrig = PulseDivider.ar(trig,2,0);
	var htrig = PulseDivider.ar(trig,2,1);
	var env = EnvGen.ar(Env.perc(0.01,1.2,curve:-5),ktrig);
	var env2 = EnvGen.ar(Env.perc(0.001,1.2,curve:-5),ktrig);
	var envh = EnvGen.ar(Env.perc(0.01,1,curve:-4),ktrig);
	var env2h = EnvGen.ar(Env.perc(0.001,0.25,3,curve:-6),htrig);
	var hiha = WhiteNoise.ar()*env2h;
	hiha = RHPF.ar(hiha,LinExp.kr(In.kr(~controls[2]),0,1,20,20000));
	Out.ar(0,{DelayL.ar(0.1*SinOsc.ar(In.kr(~controls[0])*120*env2,0,env),0.1 * In.kr(~controls[8]))}!2);

	Out.ar(0,{In.kr(~controls[1])*hiha}!2);

}.play
)
(
~controls = {Bus.control()}!56;
CCResponder({|s,ch,c,v| ~controls[c%56].set(v/128)},nil,1,{|c| c < 56}); //controls on 1
)