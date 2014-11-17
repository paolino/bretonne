(
~seq = {
	arg k,m,ro,l,j,h;
	var n=0,p=0,ls=Array.fill(l,{false});
	k.collect({|i|
		var n2 = n;
		if(ls[n%l]==true ,{p = (p + 1)%ro.size},{ls[n%l]=true});
		n = (n + ro[p]);
		[Scale.minor.degreeToFreq((i*h%(j*h)+m),80,0),n2%l]
	});
};

~puncher = {
	arg b,nn,bn,ts,nd,width,int,bars,disp;
	var seq = ~seq.value(nn,bn,ts,nd,width,int);
	seq.postln;
	seq.do({|lo|
		var w = (disp + (lo[1]/width))/bars*b.numFrames*b.numChannels;
		Synth(\punch,[
		\bufnum,b,
		\freq,lo[0],
		\amp,1,
		\where,w
		]
		)
		}
	)
};
)

b = Buffer.alloc(s, Server.local.sampleRate * 2.0, 1,18); // a four second 1 channel Buffer
{Out.ar(0, 0.2  * ({PlayBuf.ar(1,b,loop:1)}!2))}.play



(
SynthDef(name:\punch,ugenGraphFunc:
	{   |bufnum,freq,amp,where|


		var sig = RLPF.ar(VarSaw.ar(freq*{rrand(0.99,1.01)}!1,0,width:0.5),2000);
		var env2 = Env.new([0, 1, 0.9, 0], [0.1, 0.5, 1],[-5, 0, -5]);
		var env = EnvGen.ar(envelope:Env.perc(0.01,0.8),doneAction:2);
		sig = DelayC.ar(Mix.ar(sig*env),0.1,0.1);
		RecordBuf.ar(sig,bufnum,offset:where,recLevel:1,preLevel:1,loop:1);

        0
}).send

);
(
b.zero;

	~puncher.value(b,25,2,[9,14.5],16,5,2,1,0);

)


