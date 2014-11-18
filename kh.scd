({
	var trig = Impulse.ar(4.1);
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
~controls = {Bus.control()}!56;
CCResponder({|s,ch,c,v| ~controls[c%56].set(v/128)},nil,1,{|c| c < 56}); //controls on 1
