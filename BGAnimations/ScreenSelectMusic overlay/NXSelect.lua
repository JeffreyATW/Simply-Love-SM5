local af = Def.ActorFrame{
  InitCommand=cmd(blend,'BlendMode_Add';x,SCREEN_CENTER_X-400;y,SCREEN_CENTER_Y-255;);
  LoadActor( THEME:GetPathB("_shared","models/SelectMusic") )..{
  OnCommand=cmd(diffusealpha,1;zoom,70;heartbeat;effectclock,'beat';effectmagnitude,1.0,1.01,1.0;effectoffset,0.5;);
  OffCommand=cmd(linear,0.25;diffusealpha,0;);
  };
}

return af