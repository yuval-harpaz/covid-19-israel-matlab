#!/usr/bin/env python3
import pandas as pd
import numpy as np
import plotly.graph_objects as go
import dash
from dash import dcc
from dash import html
from dash.dependencies import Input, Output

# get data
df = pd.read_csv('https://raw.githubusercontent.com/yuval-harpaz/covid-19-israel-matlab/master/data/Israel/cases_by_age.csv')
x=df['date']
x = pd.to_datetime(x)
y=np.asarray(df.iloc[:,1:11])
label = ['0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70-79', '80-89', '90+']
color = ['#E617E6', '#6A17E6', '#1741E6', '#17BEE6', '#17E6BE', '#17E641', '#6AE617', '#E6E617', '#E69417', '#E61717']
# set dash
app = dash.Dash(__name__)
server = app.server
#

layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)')

# fig = go.Figure(layout=layout)
# for ii,line in enumerate(yyAge.T):
#     fig.add_trace(go.Scatter(x=x, yyAge=line,
#                         mode='lines',
#                         line_color = color[ii],
#                         name=label[ii]))

# fig.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
# fig.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
# fig.update_layout(title_text="Weekly cases by age, Israel", font_size=15)
# fig.show()
app.layout = html.Div([
    dcc.Checklist(id="checklist",
    options=[
        {'label': 'log', 'value': 'log'},
    ],
    value=[]
),
    dcc.Graph(id="line-chart")])
@app.callback(
    Output("line-chart", "figure"), 
    [Input("checklist", "value")])
def update_graph(checklist):
    print(checklist)
    fig = go.Figure(layout=layout)
    for ii,line in enumerate(y.T):
        fig.add_trace(go.Scatter(x=x, y=line,
                            mode='lines',
                            line_color = color[ii],
                            name=label[ii]))
    
    fig.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
    fig.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
    fig.update_layout(title_text="Weekly cases by age, Israel", font_size=15)
    if checklist == 'log':
        fig.update_yaxes(type="log",range=(1.2,4.3))
    else:
        fig.update_yaxes(type="linear",range=(0,20000))
    # fig.show()
    return fig

if __name__ == '__main__':
    app.run_server(debug=True)
