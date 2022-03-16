---
layout: single
title:  "Unit Testing for Machine Learning"
date:   2017-10-21 10:00:00 +0530
categories: engineering
tags: machine-learning
---

Would love to share a [great article](https://medium.com/@keeper6928/how-to-unit-test-machine-learning-code-57cf6fd81765) that I read today.

Some key points to take away from here.

1. You can have a common set of tests (such as trainable parameters, shape validation, etc…) written that can be re-used across all your ML code. Think of it as your common regression suite.
2. Look at Udacity’s [Deep Learning code](https://github.com/udacity/deep-learning), most of the projects already have unit test stubs written so that the student can test against it, while developing their code. This is a great idea to continue during your own development as well.
3. And since most of ML is written in python anyway, it’s an even greater idea to pair
[Chase Roberts’s](https://medium.com/u/9e396dff421b) idea with python unit testing frameworks. Here are [some](https://jeffknupp.com/blog/2013/12/09/improve-your-python-understanding-unit-testing/) [fantastic](http://docs.python-guide.org/en/latest/writing/tests/) [articles](https://cgoldberg.github.io/python-unittest-tutorial/) to get you started.
