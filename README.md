TVHeadFish
==========

TVHeadFish is my attempt to create a TVHeadEnd client for Sailfish OS. To use it, you need the IP address and port number where your TVHeadEnd server is running. At this point, I'm assuming that no authentication is required. If you have authentication set up, this is not going to work for you at this point.

Once you have connected, you should see a list of channels. You can click on any channel to view the schedule. In the schedule view, you can use the pulley menu to watch live tv or to go to your 'Finished Recordings' view.

Video playback is touch and go... it seems to work okay for some channels and not so well for others.... sometimes even crashing the application. Same as for watching Finished Recordings. Maybe this is related to codecs or stream buffering. I am still trying to work this out.

Anyway, I thought I would put this up now, since I am starting to make a fair bit of progress on it.

I just spoke to Adam Sutton (a lead developer for TVHeadend) and he pointed out that I am using an undocumented API and that I should change my code to use HTSP directly... which is a good point, but which is going to take me some time to get around to. Meanwhile, since this is just using HTTP calls against a shifting API.

Important: If you were using TVHeadend 3.5, TVHeadFish 0.3 is the last version that supports this. I upgraded my TVHeadend server to 3.9, so TVHeadFish 0.4 is a quick rewrite on some of the API calls to get a vaguely functioning version. Channel icons currently don't load in this version... but the rest of the calls seem to be working now.

Note to self: definitely start looking at writing this to use HTSP instead of the JSON API!

Feedback always useful.

