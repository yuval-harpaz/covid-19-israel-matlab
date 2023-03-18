import os
import pandas as pd
from dash import dcc, callback_context, html, Dash
from dash.dependencies import Input, Output, State
import dash_bootstrap_components as dbc
import numpy as np
from dash_dangerously_set_inner_html import DangerouslySetInnerHTML as dangerHTML

# make buttons (radio items) from excel
df = pd.read_excel('/home/innereye/Documents/דמוגרפיה.xlsx', 'features', header=None)
df1 = pd.read_excel('/home/innereye/Documents/דמוגרפיה.xlsx', 'Main Table', header=None)
# where each minority start and ends
subheader = []
for col in range(3, len(df1.columns)):
    if type(df1[df1.columns[col]][0]) == str:
        subheader.append([int(col), len(df1.columns)])
        if col > 3:
            subheader[-2][1] = int(col)-1
issue = []
for isu in range(2, len(df1)):
    tmp = {'row': int(isu), 'description': df1[0][isu], 'example': df1[1][isu], 'ref': df1[2][isu]}
    add = []
    for su in subheader:
        vv = df1.iloc[isu][su[0]:su[1]+1].to_numpy()
        idx = np.where(vv == 1.0)[0]
        if len(idx) > 0:
            for jdx in range(len(idx)):
                add.append([df1.iloc[0][su[0]], df1.iloc[1][np.arange(su[0], su[1]+1)[idx[jdx]]]])
    tmp['group'] = add
    issue.append(tmp)


buttons = {}
for ii in range(0, len(df), 2):  # fields
    col = 1
    vals = []
    while (col < len(df.columns)) and (type(df[col][ii+1]) == str):
        vals.append(df[col][ii+1])
        col += 1
    buttons[df[1][ii]] = vals

# prepare radio items options
btname = list(buttons.keys())
opt = []
for ibtn in range(len(btname)):
    op = []
    for ibv in range(len(buttons[btname[ibtn]])):
        bl = buttons[btname[ibtn]][ibv]
        bv = btname[ibtn]+'_'+str(ibv)
        op.append({'label': bl, 'value': bv})
    opt.append(op)
text = 'long story short'

# make a table to download with a button
dfdownload = pd.DataFrame(['nothing yet'], columns=['anything'])

## start making the web app
app = Dash(
    __name__,
    external_stylesheets=[dbc.themes.BOOTSTRAP],
    meta_tags=[{"name": "viewport", "content": "width=device-width, initial-scale=1"}]
)
server = app.server
app.layout = html.Div([
    html.Div([
        html.Div([dbc.Row([dbc.Col(' ', lg=1),dbc.Col([
            html.H3('מחשבון אפליה')])]),
            html.Br(), html.Br()
        ]),  # dbc.col([dbc.Col([html.A(btname[ibtn]),html.A(' : ')])]),
        dbc.Row([
            dbc.Col(' ', lg=1),
            dbc.Col([
                dbc.Row([html.A(btname[ibtn]),
                    dcc.RadioItems(id=str(ibtn),
                    options=opt[ibtn],
                    value=opt[ibtn][0]['value'],
                    labelStyle={'display': 'inline-block'}
                )]) for ibtn in range(len(btname))
            ], lg=2),
            dbc.Col([html.Div(html.A(text, id='text', dir='rtl'), style={'whiteSpace': 'pre-wrap', 'text-align': 'right'})], lg=8, align='start')
        ,dbc.Col(' ', lg=1)], justify='end'),
        html.Br(), html.Br(), html.Br(),
    ])
])


## callback functions for interactive items
# change text according to choices
@app.callback(
    Output('text', 'children'),
    Input('0', 'value'),
    Input('1', 'value'),
    Input('2', 'value'),
    )
def update_text(*args):
    field = []
    value = []
    for arg in args:
        ibtn = []
        for jbtn in range(len(btname)):
            if btname[jbtn] == arg[:arg.index('_')]:
                ibtn.append(jbtn)
        if len(ibtn) == 1:
            ibtn = ibtn[0]
        else:
            raise Exception('button names should be unique')
        field.append(btname[ibtn])
        value.append(opt[ibtn][int(arg[arg.index('_')+1:])]['label'])

    reasons = ['']*len(issue)
    for iis in range(len(issue)):  # go over issues one by one
        for iig in range(len(issue[iis]['group'])):  # each issues have a few relevant minority groups
            for iif in range(len(field)):  # compare with filled fields
                if issue[iis]['group'][iig][0] == field[iif] and issue[iis]['group'][iig][1] == value[iif]:
                    reasons[iis] = reasons[iis] + field[iif] + ': ' + value[iif] + ', '
    optext = ''
    for iis in range(len(issue)):
        if len(reasons[iis]) > 0:
            optext = optext + reasons[iis][:-2]+'\n' + \
                     issue[iis]['description']+'\n' + \
                     issue[iis]['example']+'\n' + \
                     issue[iis]['ref']+'\n'

    return optext


# download csv
# @app.callback(
#     Output("download-text", "data"),
#     Input("btn-download-txt", "n_clicks"),
#     prevent_initial_call=True
# )
# def func(n_clicks):
#     return dict(content=dfdownload.to_csv(index=False), filename="discrimination.csv")


# run. see page on http://127.0.0.1:8050/
if __name__ == '__main__':
    app.run_server(debug=True)

