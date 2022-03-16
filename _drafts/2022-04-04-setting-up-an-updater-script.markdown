---
layout: single
title:  "Keeping your system always up to date"
date:   2022-03-24 10:00:00 +0530
categories: engineering
tags: automation
---
This is a small nitpick of a post. I love when my PC / system / technology is always up to date. Not like hey, there have been updates nagging me for the last few months, so let me do it. It's more like, an app that I've never used has an update 2 minutes back, and OH SHIT i've not updated yet. So to appease my insanity, this is what I do across the different Operating Systems.

## Windows
Please tell me you folks know of [Chocolatey](https://chocolatey.org/)! If not, please please, pretty please go and look at it. Once Chocolatey is installed, you can find pretty much every tool / app that you use in windows to part of chocolatey. You can find the list of all packages [here](https://community.chocolatey.org/packages). I even push to the extent of installing my browsers, microsoft word, VLC, etc... using chocolatey. So why does Choco help me, because I can now update all the apps/libraries/tools in my system with a single command `cup all -y`

## MacOS
[Homebrew](https://brew.sh/) is the holy grail of package managers for MacOS. It does it's job phenomenolly well. Including taking care of the new M1 silicon support relatively well. Most developers would also have a ton of other package managers / devtools installed on their system. So this is my update script which is "cronned" to run every day morning
```
softwareupdate -l # updates the MacOS itself and any app updates (such as xcode, etc...) that the OS itself manages.
brew update
brew upgrade
brew cleanup
conda update --all -y # Updates all the python packages in the base conda environment
pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip3 install -U # Updates all the pip packages
npm install -g npm # Updates npm itself
npm update -g # Updates all the npm global packages
```

## Linux
The change with the above script would be the following
```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade
sudo apt-get clean
conda update --all -y # Updates all the python packages in the base conda environment
pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip3 install -U # Updates all the pip packages
npm install -g npm # Updates npm itself
npm update -g # Updates all the npm global packages
```
