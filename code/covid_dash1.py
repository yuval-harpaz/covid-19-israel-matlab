import pandas as pd
import numpy as np
import plotly.graph_objects as go
import dash
from dash import dcc
from dash import html
import plotly.express as px
import os
# get age data
if os.path.isfile('/home/innereye/Downloads/VerfiiedVaccinationStatusDaily'):
    api = '/home/innereye/Downloads/'
    df = pd.read_csv(
        '/home/innereye/covid-19-israel-matlab/data/Israel/cases_by_age.csv')
else:
    api = 'https://datadashboardapi.health.gov.il/api/queries/'
    df = pd.read_csv(
        'https://raw.githubusercontent.com/yuval-harpaz/covid-19-israel-matlab/master/data/Israel/cases_by_age.csv')
url = [api+'VerfiiedVaccinationStatusDaily',
       api+'SeriousVaccinationStatusDaily',
       api+'deathVaccinationStatusDaily']
measure = ['Cases','New Severe','Deaths']
vars = [['verified_vaccinated_normalized', 'verified_expired_normalized', 'verified_not_vaccinated_normalized'],
        ['new_serious_vaccinated_normalized', 'new_serious_expired_normalized', 'new_serious_not_vaccinated_normalized'],
        ['death_vaccinated_normalized', 'death_expired_normalized', 'death_not_vaccinated_normalized']]

dfs = [[],[],[]]
for ii in [0,1,2]:
    dfs[ii] = pd.read_json(url[ii])
    # x = dfs[ii]['date']
    # x = pd.to_datetime(x)
    dfs[ii]['date'] = pd.to_datetime(dfs[ii]['day_date'])
    dfs[ii] = dfs[ii].rename(columns={vars[ii][0]: 'vaccinated', vars[ii][1]: 'expired', vars[ii][2]: 'unvaccinated'})
    # date60 = dfs[ii].loc[dfs[ii]["age_group"] == 'מעל גיל 60', "date"]
    dfs[ii] = dfs[ii][['date', 'age_group', 'vaccinated', 'expired', 'unvaccinated']]
    date = dfs[ii]['date']
    dfs[ii] = dfs[ii].rolling(7, min_periods=7).mean()
    dfs[ii]['date'] = date - pd.to_timedelta(dfs[ii].shape[0] * [3], 'd')



updatemenus = [
    dict(
        type="buttons",
        direction="down",
        buttons=list([
            dict(
                args=[{'yaxis.type': 'linear'}],
                label="Linear Scale",
                method="relayout"
            ),
            dict(
                args=[{'yaxis.type': 'log'}],
                label="Log Scale",
                method="relayout"
            )
        ])
    ),
]
x = df['date']
x = pd.to_datetime(x)
yyAge = np.asarray(df.iloc[:, 1:11])
label = ['0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70-79', '80-89', '90+']
color = ['#E617E6', '#6A17E6', '#1741E6', '#17BEE6', '#17E6BE', '#17E641', '#6AE617', '#E6E617', '#E69417', '#E61717']
layout = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)',legend={'traceorder':'reversed'})
fig1 = go.Figure(layout=layout)
for ii, line in enumerate(yyAge.T):
    fig1.add_trace(go.Scatter(x=x, y=line,
                        mode='lines',
                        line_color = color[ii],
                        name=label[ii]))

fig1.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
fig1.update_yaxes(range=(20, 19000))
fig1.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
fig1.update_layout(title_text="Weekly cases by age, Israel", font_size=15, updatemenus=updatemenus)


def make_figs3(df_in):
    df_age = df_in.loc[df_in["age_group"] == 'מעל גיל 60']
    yyInf = dfInfOld.rolling(7, min_periods=7).mean()
    yyInf['date'] = dfInfOld['date'] - pd.to_timedelta(dfInfOld.shape[0] * [3], 'd')
    yyInf = yyInf.rename(columns={'verified_vaccinated_normalized': 'vaccinated',
                                  'verified_expired_normalized': 'expired',
                                  'verified_not_vaccinated_normalized': 'unvaccinated'})
app = dash.Dash(__name__)
app = dash.Dash(
    __name__,
    external_stylesheets=[
        'https://codepen.io/chriddyp/pen/bWLwgP.css'
    ]
)
server = app.server
app.layout = html.Div([
    html.Div([
        html.Div([
            html.H3('Israel COVID19 data'),
            html.Spacer('zoom in (click and drag) and out (double click), adapted from the '),
            html.A('dashboard', href="https://datadashboard.health.gov.il/COVID-19/general?utm_source=go.gov.il&utm_medium=referral", target='_blank'),
            html.Spacer(' by '),
            html.A('@yuvharpaz', href="https://twitter.com/yuvharpaz", target='_blank'),
            html.Br(), html.Br()
        ], className="row"),
        html.Div([
            html.Div([
                dcc.RadioItems(
                    options=[
                        {'label': '60+', 'value': 'מעל גיל 60'},
                        {'label': '<60', 'value': 'מתחת לגיל 60'}
                    ],
                    value='מעל גיל 60',
                    labelStyle={'display': 'inline-block'}
                )
            ]),

            html.Div([
                dcc.RadioItems(
                    options=[
                        {'label': 'absolute', 'value': 'absolute'},
                        {'label': 'per 100k', 'value': 'normalized'}
                    ],
                    value='normalized',
                    labelStyle={'display': 'inline-block'}
                )
            ]),
            # html.Div([dcc.RadioItems()], className="six columns"),

        ], className="row"),

        html.Div([
            html.Div([
                # html.H3('@yuvharpaz'),
                dcc.Graph(id='g1', figure=figInf)
            ], className="six columns"),

            html.Div([
                # html.Br(), html.Br(), html.Br(), html.Br(),
                # html.H3(html.Span("Make Space", style={"color": "#ffffff"})),
                # html.Br(),
                # html.Spacer(html.Span("More Space", style={"color": "#ffffff"})),
                dcc.Graph(id='g2', figure=fig1)
            ], className="six columns"),
        ], className="row"),
        html.Div([
            html.Div([
                dcc.Graph(id='g3', figure=figSev)
            ], className="six columns"),

            html.Div([
                dcc.Graph(id='g4', figure=figDeath)
            ], className="six columns")
        ], className="row")
    ])
])
@app.callback(
    Output('indicator-graphic', 'figure'),
    Input('age', 'value'),
    Input('doNorm', 'value'))
def update_graph(age_group, norm_abs):

if __name__ == '__main__':
    app.run_server(debug=True)















# get infected data
dfInf = pd.read_json('https://datadashboardapi.health.gov.il/api/queries/VerfiiedVaccinationStatusDaily')
dfInf['date'] = pd.to_datetime(dfInf['day_date'])
date60 = dfInf.loc[dfInf["age_group"] == 'מעל גיל 60', "date"]
dfInfOld = dfInf.loc[dfInf["age_group"] == 'מעל גיל 60', ["date",
                                                          "verified_vaccinated_normalized",
                                                          'verified_expired_normalized',
                                                          "verified_not_vaccinated_normalized"]]
yyInf = dfInfOld.rolling(7, min_periods=7).mean()
yyInf['date'] = dfInfOld['date'] - pd.to_timedelta(dfInfOld.shape[0] * [3], 'd')
yyInf = yyInf.rename(columns={'verified_vaccinated_normalized': 'vaccinated',
                   'verified_expired_normalized': 'expired',
                   'verified_not_vaccinated_normalized': 'unvaccinated'})

# get severe data
dfSev = pd.read_json('https://datadashboardapi.health.gov.il/api/queries/SeriousVaccinationStatusDaily')
dfSev['date'] = pd.to_datetime(dfSev['day_date'])
# date60 = dfSev.loc[dfSev["age_group"] == 'מעל גיל 60', "date"]
dfSevOld = dfSev.loc[dfSev["age_group"] == 'מעל גיל 60', ["date",
                                                          "new_serious_vaccinated_normalized",
                                                          'new_serious_expired_normalized',
                                                          "new_serious_not_vaccinated_normalized"]]
yySev = dfSevOld.rolling(7, min_periods=7).mean()
yySev['date'] = dfSevOld['date'] - pd.to_timedelta(dfSevOld.shape[0] * [3], 'd')
yySev = yySev.rename(columns={'new_serious_vaccinated_normalized': 'vaccinated',
                   'new_serious_expired_normalized': 'expired',
                   'new_serious_not_vaccinated_normalized': 'unvaccinated'})

dfDeath = pd.read_json('https://datadashboardapi.health.gov.il/api/queries/deathVaccinationStatusDaily')
dfDeath['date'] = pd.to_datetime(dfDeath['day_date'])
dfDeathOld = dfDeath.loc[dfDeath["age_group"] == 'מעל גיל 60', ["date",
                                                          "death_vaccinated_normalized",
                                                          'death_expired_normalized',
                                                          "death_not_vaccinated_normalized"]]
yyDeath = dfDeathOld.rolling(7, min_periods=7).mean()
yyDeath['date'] = dfDeathOld['date'] - pd.to_timedelta(dfDeathOld.shape[0] * [3], 'd')
yyDeath = yyDeath.rename(columns={'death_vaccinated_normalized': 'vaccinated',
                   'death_expired_normalized': 'expired',
                   'death_not_vaccinated_normalized': 'unvaccinated'})


figInf = px.line(yyInf, x="date", y=['vaccinated', 'expired', 'unvaccinated'])
figInf['data'][0]['line']['color'] = '#0e7d7d'
figInf['data'][1]['line']['color'] = '#b9c95b'
figInf['data'][2]['line']['color'] = '#2fcdfb'
figInf.layout = layout
figInf.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray')
figInf.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
figInf.update_layout(title_text="Cases by vaccination status, per 100k people (60+)", font_size=15)

figSev = px.line(yySev, x="date", y=['vaccinated', 'expired', 'unvaccinated'])
figSev['data'][0]['line']['color'] = '#0e7d7d'
figSev['data'][1]['line']['color'] = '#b9c95b'
figSev['data'][2]['line']['color'] = '#2fcdfb'
figSev.layout = layout
figSev.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray')
figSev.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
figSev.update_layout(title_text="New severe patients by vaccination status, per 100k people (60+)", font_size=15)

figDeath = px.line(yyDeath, x="date", y=['vaccinated', 'expired', 'unvaccinated'])
figDeath['data'][0]['line']['color'] = '#0e7d7d'
figDeath['data'][1]['line']['color'] = '#b9c95b'
figDeath['data'][2]['line']['color'] = '#2fcdfb'
figDeath.layout = layout
figDeath.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray')
figDeath.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray')
figDeath.update_layout(title_text="New deaths by vaccination status, per 100k people (60+)", font_size=15)

updatemenus = [
    dict(
        type="buttons",
        direction="down",
        buttons=list([
            dict(
                args=[{'yaxis.type': 'linear'}],
                label="Linear Scale",
                method="relayout"
            ),
            dict(
                args=[{'yaxis.type': 'log'}],
                label="Log Scale",
                method="relayout"
            )
        ])
    ),
]



app = dash.Dash(__name__)
app = dash.Dash(
    __name__,
    external_stylesheets=[
        'https://codepen.io/chriddyp/pen/bWLwgP.css'
    ]
)
server = app.server
app.layout = html.Div([
    html.Div([
        html.Div([
            html.H3('Israel COVID19 data'),
            html.Spacer('zoom in (click and drag) and out (double click), adapted from the '),
            html.A('dashboard', href="https://datadashboard.health.gov.il/COVID-19/general?utm_source=go.gov.il&utm_medium=referral", target='_blank'),
            html.Spacer(' by '),
            html.A('@yuvharpaz', href="https://twitter.com/yuvharpaz", target='_blank'),
            html.Br(), html.Br()
        ], className="row"),
        html.Div([
            html.Div([
                dcc.RadioItems(
                    options=[
                        {'label': '60+', 'value': 'מעל גיל 60'},
                        {'label': '<60', 'value': 'מתחת לגיל 60'}
                    ],
                    value='מעל גיל 60',
                    labelStyle={'display': 'inline-block'}
                )
            ]),

            html.Div([
                dcc.RadioItems(
                    options=[
                        {'label': 'absolute', 'value': 'absolute'},
                        {'label': 'per 100k', 'value': 'normalized'}
                    ],
                    value='normalized',
                    labelStyle={'display': 'inline-block'}
                )
            ]),
            # html.Div([dcc.RadioItems()], className="six columns"),

        ], className="row"),

        html.Div([
            html.Div([
                # html.H3('@yuvharpaz'),
                dcc.Graph(id='g1', figure=figInf)
            ], className="six columns"),

            html.Div([
                # html.Br(), html.Br(), html.Br(), html.Br(),
                # html.H3(html.Span("Make Space", style={"color": "#ffffff"})),
                # html.Br(),
                # html.Spacer(html.Span("More Space", style={"color": "#ffffff"})),
                dcc.Graph(id='g2', figure=fig1)
            ], className="six columns"),
        ], className="row"),
        html.Div([
            html.Div([
                dcc.Graph(id='g3', figure=figSev)
            ], className="six columns"),

            html.Div([
                dcc.Graph(id='g4', figure=figDeath)
            ], className="six columns")
        ], className="row")
    ])
])
@app.callback(
    Output('indicator-graphic', 'figure'),
    Input('age', 'value'),
    Input('doNorm', 'value'))
def update_graph(age_group, norm_abs):

if __name__ == '__main__':
    app.run_server(debug=True)
