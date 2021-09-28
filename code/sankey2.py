#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep 28 01:51:48 2021

@author: innereye
"""

import plotly.graph_objects as go
import plotly.io as pio
pio.renderers.default='browser'


fig = go.Figure(data=[go.Sankey(
    node = dict(
      pad = 15,
      thickness = 40,
      line = dict(color = None),
      label = ["At home", "Mild / Medium", "Severe", "Deceased"],
      color = ["green","blue","red","black"]
    ),
    link = dict(
      source = [0, 1, 1, 1, 2, 2, 2, 2, 0], # indices correspond to labels, eg A1, A2, A1, B1, ...
      target = [1, 2, 1, 0, 0, 1, 2, 3, 3],
      value = [199, 98, 358, 163, 28, 27, 497, 20,3]
  ))])

fig.update_layout(title_text="severe outcome, 18 Aug 2021", font_size=30)
fig.show()

fig = go.Figure(data=[go.Sankey(
    node = dict(
      pad = 15,
      thickness = 40,
      line = dict(color = None),
      label = ["At home", "Mild / Medium", "Severe", "Deceased"],
      color = ["green","blue","red","black"]
    ),
    link = dict(
      source = [0, 1, 1, 1, 2, 2, 2, 2, 0], # indices correspond to labels, eg A1, A2, A1, B1, ...
      target = [1, 2, 1, 0, 0, 1, 2, 3, 3],
      value = [142, 82, 374, 168, 44, 24, 513, 17, 6]
  ))])

fig.update_layout(title_text="severe outcome, 22 Sep 2021", font_size=30)
fig.show()