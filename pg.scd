ProxySpace.new.push

~x.play;
~x = {Pan2.ar(Mix.ar( ~y.ar ))};

~y = {Pulse.ar(~f,0.4)*~z};
~z = {|ts=1| EnvGen.ar(Env.perc(curve:-8),~t,timeScale:0.4)};
~zf = {EnvGen.ar(Env.perc,~t,timeScale:2)};
~zfm = {EnvGen.ar(Env.perc,~t,timeScale:0.1)};

~t = {Impulse.kr(25/12)};
~f = {|d=70| ~zf * d};

~fm = {LFTri.ar(60 *  SinOsc.ar(101))};

~lfm = {RLPF.ar(~fm.ar,500)*~zfm};

~x.scope

~y = { Klank.ar(`[[60], nil, [1]], ~y2.ar*0.01) * ~z};
~y2 = { Klank.ar(`[[60], nil, [0.1]], PinkNoise.ar())};







w = Window.new("GUI Introduction", Rect(200,200,255,100));
b = Button.new(w,Rect(10,0,80,30)).states_([["Hide"],["Show"]]);
s = Slider.new(w,Rect(95,0,150,30));
Slider.new(w,Rect(95,0,150,30)).action = { ~z.set(\ts,s.value*2)};
c = CompositeView.new(w,Rect(20,35,100,60));
c.remove
b.remove
StaticText.new(c,Rect(0,0,80,30)).string_("Hello");
StaticText.new(c,Rect(20,30,80,30)).string_("World!");
b.action = { c.visible = b.value.asBoolean.not };
s.action = { ~f.set(\d,s.value*100)};
w.front;
~f.set(\d,55);
(
w=Window().layout_( GridLayout.rows(
    [Slider2D(), Slider2D(), [Slider(), rows:2]],
    [Slider2D(), Slider2D()],
    [[Slider().orientation_(\horizontal), columns:2]]
)).front;
)
