import pandas as pd
import requests
import json
header = {
  "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.75 Safari/537.36",
  "X-Requested-With": "XMLHttpRequest"
}
game = 0
goon = True
while goon:
    game += 1
    gamecode = "{0:0=3d}".format(game)
    url = 'https://live.euroleague.net/api/playbyplay?gamecode='+gamecode+'&seasoncode=E2021'
    r = requests.get(url, headers=header)
    if len(r.text) == 0:
        goon = False
    else:
        op = json.loads(r.text)
        for part in ['FirstQuarter', 'SecondQuarter', 'ThirdQuarter', 'ForthQuarter', 'ExtraTime']:
            df = pd.DataFrame(op[part])
            df.to_excel(op['CodeTeamA']+'_'+op['CodeTeamB']+'_' + part+'.xlsx')
