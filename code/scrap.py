import pandas as pd
import json
import urllib.request
import plotly.express as px
import plotly.graph_objects as go
import numpy as np
url1 = 'https://data.gov.il/api/3/action/datastore_search?resource_id=e4bf0ab8-ec88-4f9b-8669-f2cc78273edd&limit=10000'
with urllib.request.urlopen(url1) as api1:
    data1 = json.loads(api1.read().decode())
win =21
def movmean(vec, win, nanTail=False):
    #  smooth a vector with a moving average. win should be an odd number of samples.
    #  vec is np.ndarray size (N,) or (N,0)
    #  to get smoothing of 3 samples back and 3 samples forward use win=7

    # if len(data.shape) == 2:
    #     vec = data[:, 0]
    padded = np.concatenate(
        (np.ones((win,)) * vec[0], vec, np.ones((win,)) * vec[-1]))
    smooth = np.convolve(padded, np.ones((win,)) / win, mode='valid')
    smooth = smooth[int(win / 2) + 1:]
    smooth = smooth[0:vec.shape[0]]
    if nanTail:
        smooth[-int(win / 2):-1] = np.nan
        smooth[-1] = np.nan
        smooth[0:int(win / 2)+1] = np.nan
    return smooth



df1 = pd.DataFrame(data1['result']['records'])
date1 = np.asarray(pd.to_datetime(df1['תאריך']))

url2 = 'https://datadashboardapi.health.gov.il/api/queries/VerfiiedVaccinationStatusDaily'
df2 = pd.read_json(url2)

# dfY = df2.loc[df2["age_group"] == 'מתחת לגיל 60']
df2 = df2.loc[df2["age_group"] == 'מעל גיל 60']
df2 = df2.reset_index()
date2 = np.asarray(pd.to_datetime(df2['day_date'].str.slice(0, 10)))
date = np.concatenate([date1, date2])
date = np.unique(date)
date = np.sort(date)
vaccW60 = movmean(np.asarray(df2['verified_vaccinated_normalized']), 7, nanTail=False)
unvaccW60 = movmean(np.asarray(df2['verified_not_vaccinated_normalized']), 7, nanTail=False)
veW60 = np.round(100*(1-vaccW60/unvaccW60))
# xl = [str(np.datetime_as_string(date[288]))[0:10], str(np.datetime_as_string(date[-1]))[0:10]]

##
xlW60 = [str(np.datetime_as_string(date2[0]))[0:10], str(np.datetime_as_string(date2[-1]+np.timedelta64(1, 'D')))[0:10]]
layoutW60 = go.Layout(paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', xaxis_range=xlW60)  #, xaxis_range=xl)
figW60 = go.Figure(layout=layoutW60)
figW60.add_trace(go.Scatter(x=date2, y=veW60, name='VE 3 doses', line_color='#222277'))
figW60.add_trace(go.Scatter(x=date2[-4:], y=veW60[-4:], name='not final', line_color='#aaaaaa'))
figW60.update_yaxes(range=[-50, 100], dtick=10, zeroline=True, zerolinecolor='#aaaaaa', gridcolor='#bdbdbd')
figW60.add_trace(go.Scatter(x=date2, y=vaccW60, yaxis='y2', name='vaccinated', line_color='#99ff99'))
figW60.update_xaxes(dtick="M1", tickformat="%d-%b \n%Y", gridcolor='#bdbdbd')
figW60.update_layout(
    yaxis_title="crude VE (%)",
    yaxis=dict(
            tickmode='linear',
            zeroline=True,
            ),
    legend=dict(
                    yanchor="top",
                    y=1.1,
                    xanchor="left",
                    x=1.05
                ),
    title_text="Crude VE (60+) vs cases", font_size=15, hovermode="x unified",
    yaxis2=dict(
        title="Cases per 100k",
        color='#ff9999',
        anchor="free",
        overlaying="y",
        side="right",
        position=1,
        zerolinecolor='lightgray',
        gridcolor='lightgray',
        zeroline=True,
        range=[0, 150]
    ))
figW60.add_trace(go.Scatter(x=date2, y=unvaccW60, yaxis='y2', name='unvaccinated', line_color='#ff9999'))
figW60.show()

