---
layout      : single
title       : "Simple daily stand-up on Slack"
date        : 2022-03-27 10:00:00 +0530
categories  : leadership
tags        : management remote slack
toc         : true
---
# Why this is useful
Setting up a simple, yet periodic stand-up on an async medium like slack allows the team to
* Get to know what each other is doing in a simple, low barrier way
* Jump in and help each other on demand as they see other team members having issues
* Not waste time on stand-up meetings every day and only sync on specific topics as needed, where the discussion is purely technical

# How to set it up
* Open Slack Workflow builder
* Create new
* Set Trigger as Shortcut
* Select your common team channel and set the shortcut name as `Daily Stand-up`, or whatever name your team fancies
* Select the action as `open a form` with the following information
  * Name: `Daily Stand-up`
  * Questions:
    * `What I worked on yesterday?`
    * `What I plan to work on today?`
    * `I'm stuck on:`
  * Select send submitted responses back to the same channel.
* Save and deploy the workflow
The final workflow settings should look like
![Workflow settings](/assets/images/2022-03-27/2022-03-27-settings.webp){: .align-center}

The trigger settings should look like
![Trigger settings](/assets/images/2022-03-27/2022-03-27-trigger.webp){: .align-center}

The action settings should look like
![Action settings](/assets/images/2022-03-27/2022-03-27-action.webp){: .align-center}

# How to use
Now the team can use this daily by clicking on the bottom left `+` sign and selecting the newly created workflow. This will pop-up a form like this
![Pop-up](/assets/images/2022-03-27/2022-03-27-popup.webp){: .align-center}

The team can now fill this form daily and the entire team can see what each person is working on. They can look at the response for "I'm stuck on" and immediately jump into and help to ensure that no one feels alone or struggles alone.

# Bringing in consistency
For any habit, bringing in consistency is the key and the most difficult part. While most team members like to see what others are working on, the activity to keep others updated (especially in a remote environment) doesn't come naturally. And this isn't anyone's fault, but rather a side effect of being isolated. Few tips
1. The leaders and senior folks in the channel must post regularly. Don't believe that you are above this, if you do, your team will also feel so.
2. Ensure that the team knows and feels (a light year of a difference) that this is not used to track performance but is rather a way for the team to come together.
3. If you see members not posting regularly (and you can check in the `activity` part of the workflow), privately reach out to them and hear them out. Ask them how they would like to improve this system and what they feel is lacking. Maybe this system is not for the team if majority of them feel this way. But let them become a part of the solution, a way for the team to closely work together in this async world.