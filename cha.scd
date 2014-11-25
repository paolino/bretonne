Server.local.options.memSize=100000;
s.boot;
(
~groove = [0.05,0,0.05,0];
~amps = [1,0.5,0.8,0.5];
~seq = {
	arg k,m,ro,l,j,h,groove,amps;
	var n=0,p=0,ls=Array.fill(l,{false});
	k.collect({|i|
		var n2 = n;
		var in = n2%(l/4);
		if(ls[n%l]==true ,{p = (p + 1)%ro.size},{ls[n%l]=true});
		n = (n + ro[p]);

		[Scale.phrygian.degreeToFreq((i*h%(j*h)+m),80,0),((n2%l).floor + groove[in]),amps[in]]

	});
};

~puncher = {

	arg bnum,nn,bn,ts,nd,width,int,bars,disp,groove,amps;
	var seq = ~seq.value(nn,bn,ts,nd,width,int,groove,amps);
	~help = seq;
	seq.do({|lo|
		var w = (disp + (lo[1]/nd))/bars*bnum.numFrames*bnum.numChannels;
		//[w,width,lo[1],disp,bars,bnum.numFrames*bnum.numChannels].postln;
		Synth(\punch,[
		\bufnum,bnum,
		\freq,lo[0],
			\amp,70/lo[0]*lo[2],

		\where,w
		]
		)
		}
	)
};
~cond=true;
)
Scale.directory;

(
~b1 = Buffer.alloc(s, Server.local.sampleRate * 2.0, 1,18); // a four second 1 channel Buffer
~b2 = Buffer.alloc(s, Server.local.sampleRate * 2.0, 1,19); // a four second 1 channel Buffer

~tdbuf = Bus.control();
~reset = Bus.control();
{Out.kr(~reset,Impulse.kr(0.5))}.play
)
~switch = Bus.control();
(
SynthDef(\dbuf,{
	var b = In.kr(~tdbuf);
	var phase = Sweep.ar(In.kr(~reset), BufSampleRate.kr(b));
	var sig = BufRd.ar(1,b, phase,0,4);
	//var sig = SinOsc.ar;
	Out.ar(0,0.2* {sig}!2)
	}).play
)
~tdbuf.set(8)
(
SynthDef(name:\punch,ugenGraphFunc:
	{   |bufnum,freq,amp,where|

		var sig = SinOsc.ar([freq],SinOsc.ar([freq,freq*2.01])*2);
		var env = EnvGen.ar(envelope:Env.perc(0.003,0.3,curve:0));
		sig = FreqShift.ar(sig,sig);
	sig = DelayL.ar(Mix.ar(sig*env*[amp,amp/4]),0.2,0.04);
		RecordBuf.ar(sig,bufnum,offset:where,recLevel:1,preLevel:1);
		DetectSilence.ar(sig,0.00001,0.1,2);

        0
}).send;
~cond=true;
);
FreqScope()
~tdbuf.set(~b2.bufnum);
(
~punchit = {|b,nn,bn,ts,nd,width,int,bars,disp,groove,amps|
	Routine.run{
		b.zero;
		//s.sync()

		~puncher.value(b,nn,bn,ts,nd,width,int,bars,disp,groove,amps);
		s.sync();
		~tdbuf.set(b.bufnum)

	}
}
)
~cond=false;
(
var nnote=0,bnote=12,width=3,step=1,ro=[1,1],groove=[0,0,0,0],amps=[0.5,0.5,0.5,0.5];
CCResponder.removeAll();
CCResponder({|s,ch,c,v| nnote = v; ~cond= true;},nil,1,0); //controls on 1
CCResponder({|s,ch,c,v| bnote = v; ~cond= true;},nil,1,1); //controls on 1
CCResponder({|s,ch,c,v| width = v/4; ~cond= true;},nil,1,2); //controls on 1
CCResponder({|s,ch,c,v| step = v/16; ~cond= true;},nil,1,3); //controls on 1
CCResponder({|s,ch,c,v| ro[c-16] = v/4; ~cond= true;},nil,1,{|c| (c >= 16) && (c <18)}); //controls on 1
CCResponder({|s,ch,c,v| groove[c-8] = v/256; ~cond= true;},nil,1,{|c| (c >= 8) && (c <20)}); //controls on 1
CCResponder({|s,ch,c,v| ro[c-16] = v/4; ~cond= true;},nil,1,{|c| (c >= 20) && (c <24)}); //controls on 1

~bs = [~b1,~b2];
~nb = 0;

~r.stop;
~cond=true;

~r = Routine.run{

	inf.do({
		var b = ~bs[~nb];
	    if(~cond,{
			~nb = ~nb + 1 % 2;
			~punchit.value(b,nnote,bnote - 12,ro,16,width,step,1,0,groove,amps);
			b.postln;
			~cond=false;
		},{});
		0.3.wait;
		});

}
)
~help
