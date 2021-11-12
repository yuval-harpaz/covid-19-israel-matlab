import pandas as pd
import numpy as np
import plotly.graph_objects as go
import dash
from dash import dcc
from dash import html
import plotly.express as px
import os
from dash.dependencies import Input, Output

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
measure = ['Cases', 'New Severe', 'Deaths']
varsNorm = [['verified_vaccinated_normalized', 'verified_expired_normalized', 'verified_not_vaccinated_normalized'],
            ['new_serious_vaccinated_normalized', 'new_serious_expired_normalized', 'new_serious_not_vaccinated_normalized'],
            ['death_vaccinated_normalized', 'death_expired_normalized', 'death_not_vaccinated_normalized']]
varsAbs = [['verified_amount_vaccinated', 'verified_amount_expired', 'verified_amount_not_vaccinated'],
        ['new_serious_amount_vaccinated', 'new_serious_amount_expired', 'new_serious_amount_not_vaccinated'],
        ['death_amount_vaccinated', 'death_amount_expired', 'death_amount_not_vaccinated']]

dfsNorm = [[], [], []]
dfsAbs = [[], [], []]
for ii in [0, 1, 2]:
    dfs = pd.read_json(url[ii])
    dfs['date'] = pd.to_datetime(dfs['day_date'])
    dfsNorm[ii] = dfs.rename(columns={varsNorm[ii][0]: 'vaccinated', varsNorm[ii][1]: 'expired', varsNorm[ii][2]: 'unvaccinated'})
    dfsNorm[ii] = dfsNorm[ii][['date', 'age_group', 'vaccinated', 'expired', 'unvaccinated']]
    dfsAbs[ii] = dfs.rename(columns={varsAbs[ii][0]: 'vaccinated', varsAbs[ii][1]: 'expired', varsAbs[ii][2]: 'unvaccinated'})
    dfsAbs[ii] = dfsAbs[ii][['date', 'age_group', 'vaccinated', 'expired', 'unvaccinated']]




updatemenus = [
    dict(
        type="buttons",
        direction="down",
        buttons=list([
            dict(
                args=[{'yaxis.type': 'linear'}],
                label="Linear",
                method="relayout"
            ),
            dict(
                args=[{'yaxis.type': 'log'}],
                label="Log",
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


def make_figs3(df_in, meas, age_gr='מעל גיל 60', smoo='sm', nrm=', per 100k '):
    df_age = df_in.loc[df_in["age_group"] == age_gr]
    date = df_age['date']
    mx = np.max(df_age.max()[2:5])*1.05
    xl = [df_age.iloc[0,0], df_age.iloc[-1,0]]
    if smoo == 'sm':
        df_age = df_age.rolling(7, min_periods=7).mean()
        df_age['date'] = date - pd.to_timedelta(df_age.shape[0] * [3], 'd')
    fig = px.line(df_age, x="date", y=['vaccinated', 'expired', 'unvaccinated'])
    fig['data'][0]['line']['color'] = '#0e7d7d'
    fig['data'][1]['line']['color'] = '#b9c95b'
    fig['data'][2]['line']['color'] = '#2fcdfb'
    fig.layout = layout
    fig.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', zerolinecolor='lightgray',
                     range=[0, mx])
    fig.update_xaxes(showgrid=True, gridwidth=1, gridcolor='lightgray', range=xl)
    if age_gr == 'מעל גיל 60':
        txt60 = '(60+)'
    else:
        txt60 = '(<60)'
    fig.update_layout(title_text=meas+' by vaccination status'+nrm+txt60, font_size=15)
    return fig

app = dash.Dash(
    __name__,
    external_stylesheets=['https://codepen.io/chriddyp/pen/bWLwgP.css'],
    # meta_tags=[{"name": "viewport", "content": "width=device-width, initial-scale=1"}]
)
server = app.server
app.layout = html.Div([
    html.Div([
        html.Div([
            html.H3('Israel COVID19 data'),
            html.Spacer('zoom in (click and drag) and out (double click), adapted from the MOH '),
            html.A('dashboard', href="https://datadashboard.health.gov.il/COVID-19/general?utm_source=go.gov.il&utm_medium=referral", target='_blank'),
            html.Spacer(' by '),
            html.A('@yuvharpaz', href="https://twitter.com/yuvharpaz", target='_blank'),
            html.Br(), html.Br()
        ], className="row"),
        html.Div([
            html.Div([
                dcc.RadioItems(id='age',
                    options=[
                        {'label': '60+', 'value': 'מעל גיל 60'},
                        {'label': '<60', 'value': 'מתחת לגיל 60'}
                    ],
                    value='מעל גיל 60',
                    labelStyle={'display': 'inline-block'}
                )
            ], className="one columns"),
            html.Div([
                dcc.RadioItems(id='doNorm',
                    options=[
                        {'label': 'absolute', 'value': 'absolute'},
                        {'label': 'per 100k', 'value': 'normalized'}
                    ],
                    value='normalized',
                    labelStyle={'display': 'inline-block'}
                )
            ], className="one columns"),
            html.Div([
                dcc.RadioItems(id='smoo',
                    options=[
                        {'label': 'smooth', 'value': 'sm'},
                        {'label': 'raw', 'value': 'rw'}
                    ],
                    value='sm',
                    labelStyle={'display': 'inline-block'}
                )
            ], className="one columns"),
        ], className="row"),
        html.Div([
            html.Div([
                dcc.Graph(id='infected')
            ], className="six columns"),
            html.Div([
                dcc.Graph(id='g2', figure=fig1)
            ], className="six columns"),
        ], className="row"),
        html.Div([
            html.Div([
                # dcc.Graph(id='g3', figure=make_figs3(dfsNorm[1], measure[1]))
                dcc.Graph(id='severe')
            ], className="six columns"),
            html.Div([
                dcc.Graph(id='death')
            ], className="six columns")
        ], className="row")
    ])
])
@app.callback(
    Output('infected', 'figure'),
    Output('severe', 'figure'),
    Output('death', 'figure'),
    Input('age', 'value'),
    Input('doNorm', 'value'),
    Input('smoo', 'value'))
def update_graph(age_group, norm_abs, smoo):
    if norm_abs == 'normalized':
        figb = make_figs3(dfsNorm[0], measure[0], age_group, smoo, ', per 100k ')
        figc = make_figs3(dfsNorm[1], measure[1], age_group, smoo, ', per 100k ')
        figd = make_figs3(dfsNorm[2], measure[2], age_group, smoo, ', per 100k ')
    else:
        figb = make_figs3(dfsAbs[0], measure[0], age_group, smoo,  ' ')
        figc = make_figs3(dfsAbs[1], measure[1], age_group, smoo,  ' ')
        figd = make_figs3(dfsAbs[2], measure[2], age_group, smoo, ' ')
    return figb, figc, figd
if __name__ == '__main__':
    app.run_server(debug=True)





