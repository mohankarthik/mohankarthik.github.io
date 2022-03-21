---
layout: single
title:  "Introduction to Automotive Networks"
date:   2022-04-03 10:00:00 +0530
categories: engineering
tags: embedded automotive networks ethernet
toc: true
---
# Why do we need automotive networks
The internet has forever changed the way we interact with the world, and has deeply embedded itself into our lives. More and more devices are now connected and getting "smarter"! While the term "smarter" is debatable: I would like my TV to simply play what I command via the remote rather than tell me a million times "I can't understand what you said" (thank you Alexa!). 

As this revolution happens, a silent, albiet very powerful upgrade has been happening within our cars. And I don't just mean that automobiles are getting connected and you can control them via your mobile, but how the various devices within a car talk to each other.

## Evolution of the Electronic Control Unit (ECU)
An ECU is a small computer in your car that is responsible for controlling a specific feature (say brakes, traction control, steering, etc...). Over the years, the number of ECUs in the car have exploded from a few 10s of ECUs to more than 100s of ECUs in each car. No longer are these crucial components mechanically controlled. The original car used to have a brake pedal connected to the brake piston via brake fluid and transmits the pressure on the brake pedal to the brake pads to bring the car to a stop.

![Mechanical brakes](/assets/images/2022-04-03/2022-04-03-mechanical-braking.webp){: .align-center}
Mechanical braking - [Image credit](https://projectsgeek.com/2020/03/mechanical-braking-system-project.html)
{: .text-center}

Now, no more; when you press the brake pedal, a sensor ECU now collects the pressure on the pedal, encodes it into a message and sends it to another ECU that controls the brakes. The recieving ECU processes the incoming message, and then actuates not just the brakes, but the powertrain too to bring the car to a stop!

![Electric brakes](/assets/images/2022-04-03/2022-04-03-electric-brake.webp){: .align-center}
Audi e-tron's electronic braking - [Image credit](https://www.autoevolution.com/news/what-is-brake-by-wire-and-how-it-works-150856.html)
{: .text-center}

## Explosion of ECUs
Thanks to the speed at which features are being added into automobiles, pretty much every function is turning into an electronic component. 

The following image shows the different major electronic systems in the car. And this is still a very bird's eye view and misses showing many of the sub-systems that exists.

![ECUs in a car ](/assets/images/2022-04-03-electonic-components-in-car.webp){: .align-center}
ECUs in a car - [Image credit](https://autotechdrive.com/electronic-control-unit/)
{: .text-center}

Thanks to this, the average number of ECUs in the car has been growing exponentially. A lot more due to the disruption by non traditional OEMs such as Telsa, Rivian, etc...

![Average ECUs in a car](/assets/images/2022-04-03-average-ecus-in-car.webp){: .align-center}
Average ECUs in a car - [Image credit](https://www.greencarcongress.com/2015/07/20150729-berger.html)
{: .text-center}

And with this, the market has also been expanding rapidly.

![ECU market](/assets/images/2022-04-03/2022-04-03-average-ecu-market.webp){: .align-center}
ECU market - [Image credit](https://www.marketsandmarkets.com/Market-Reports/automotive-ecu-market-34863602.html)
{: .text-center}

# Evolution of automotive networks
Given how the automotive ECU's have exploded, the need for good and robust networking solutions have also increased! When it comes to automotive networks, there are two major segments:
* Control plane (powertrain, chassis, errors, etc...)
* Media plane (entertainment, infortainment, etc...)

This division is historical and has started merging into a single entity lately. But for the sake of a good story (who doesn't like a good story, that too about networks /s), let's understand the evolution here.

## Control plane
The control plane is primarily focused on getting sensor data to actuators.

![Sensor-Controller-Actuator](/assets/images/2022-04-03/2022-04-03-sensor-controller-actuator.webp){: .align-center}
Sensor - Controller - Actuator - [Image credit](https://www.geeksforgeeks.org/actuators-in-iot/)
{: .text-center}

Sensors are ECUs / components that sense different information, say the pressure on the brake / acceleration pedals; the fuel level of the car; a radar signal to measure the distance of the car in front; a crash sensor to inform if an accident is occuring, etc... 

Actuators on the other hand are components that perform actions. A brake actuator that actually brings the car to a stop, an airbag actuator that deploys the airbag on certain condtions, a speed actuator that controls the speed of the car depending on the cruise-control or the driver's acceleration input.

Between these two components is the controller ECU. This is the one that would recieve inputs from different sensors, understand the inputs and take decisions. For instance, an airbag controller would look at inputs from the crash sensor, but also from occupancy sensors (sensors that tell if a passenger is present or not). It would then check to see from other sensors to confirm a crash (say from a radar or from an inertial measurement unit) and then send an actuation message to airbag actuators where passengers are present to deploy the airbag. This of course is gross simplification since it would take many articles to talk just about the [airbag flow](https://www.hella.com/techworld/uk/Technical/Car-electronics-and-electrics/Car-airbag-system-3083/).

For obvious reasons, this plane needs to be secure and safe. Secure meaning that it should not allow unauthorized access and safe meaning that an error (either in the ecu, or the network) should be immediately highlighted, there should be redundancies and the car should reach a safe state that minimizes the loss of life. This is covered in detail under [ISO26262](https://en.wikipedia.org/wiki/ISO_26262) and [Automotive Cybersecurity](https://www.nhtsa.gov/technology-innovation/vehicle-cybersecurity). Topics for another day.

## Media plane
The media plane is primarily focused on getting entertainment information to the passengers. Essentially getting netflix, youtube to our spoiled asses as we drive, allowing us to make calls in and out, etc... As more and more of the car gets autonomous, the main differentiating factor is the in cabin experience and getting the media plane right goes a long way in securing good customer experience.

As opposed to the control plane, the networks in the media plane is focused on bandwidth and latency. Safety and security are still important, but not to the same level as the control plane.

## Automotive Networks
Now that we've detailed out the two planes, let's look at the various different automotive network protocols that exist in cars today. 

![Automotive Networks](/assets/images/2022-04-03/2022-04-03-automotive-networks.webp){: .align-center}
Automotive Networks - [Image credit](https://standards.ieee.org/wp-content/uploads/import/documents/other/d1-03_matheus_evolution_of_ethernet_based_automotive_networks.pdf)
{: .text-center}

![Automotive Networks in cars](/assets/images/2022-04-03/2022-04-03-automotive-networks-in-car.webp){: .align-center}
Automotive Networks in car - [Image credit](https://silvaco.com/blog/design-ip-for-automotive-socs-trends-and-solutions/)
{: .text-center}

<em>Now an obvious question would be, why the hell do we've so many networks and not just one! If only the world of engineering always agreed. Each of these networks evolved for a specialized use-case and they continue to be used either because they are already in production, and it's difficult to change; or they solve a use-case so specific that a generic network cannot solve</em>

The most popular networks are
* Controller Area Network (CAN): Developed by Bosch in 1983, it is still the most commonly used automotive network in the car for all things related to the control plane. 
* Local Interconnect Network (LIN): Developed by a group of OEMs (BMW, Volkswagen Group, Audi, Volvo Cars, Mercedes-Benz) in 2002, LIN became the low cost, simpler alternative to CAN focusing on last mile connectivity again for control plane. 
* Media Oriented System Transport (MOST): Developed by SMSC (today owned by Microchip) with the primary aim to address the media plane with bandwidth going from 25mpbs to 150mbps today. This is currently the defacto network in every car for entertainment data.
* Ethernet: Surprisingly Ethernet is yet to enter mainstream automotive networks in a big way. While most cars on road today have a small sprinkling of Ethernet and it's growing exponentially, there is a big historical reason why it took so long for Ethernet to penetrate the Automotive market.

In the next edition of this series, we'll talk about how the automotive network architecture has evolved and the networks themselves in more detail.