s.boot;
MIDIIn.connectAll;
(
var x=Synth(\bass,[\freq,200,\amp,0.1]);

var c = CCResponder({ |src,chan,num,value|
	x.set(\freq,100 + value/128*100);
    });
    c.learn;
f = {
		var d = CCResponder({ |src,chan,numa,value|
			x.set(\in,1 + value/128*5);});

		d.learn; // wait for the first controller

	};
)
f.value();




CCResponder.removeAll;

[y,z] = x.value()

)
c = CCResponder({ |src,chan,num,value|
	x.set(\in,1 + value/128*5);
    });
    c.learn; // wait for the first controller
CCResponder.removeAll;
(
SynthDef(
    \bass,                 // the name of the synthdef
    {                     // the ugenGraphFunc with actual code
        arg freq,amp,in,sin,le,phase;
		//var env= EnvGen.kr(Env.perc (releaseTime:in/amp), doneAction: 2);
		var mod=SinOsc.kr(in,In.kr(phase)).squared.squared.squared;
		var sig= Mix.fill(20,{
			VarSaw.ar(freq *Rand(0.995,1.01),Rand(0,pi/4),ExpRand(0.07,0.5));
		});
		Out.ar(0,Pan2.ar(mod*amp*sig));

    }
).send(s);
)


(
CCResponder.removeAll;
p = Bus.control(s);
c = CCResponder({ |src,chan,num,value|
	p.set(value/128*pi);
    });
    c.learn; // wait for the first controller
[1,2,3,5,7].do {|i|
	Synth(\bass,[\freq,80,\amp,0.1,\in,i,\phase,p]);
}
)

