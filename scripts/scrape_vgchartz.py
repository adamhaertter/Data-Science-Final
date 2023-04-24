from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
import csv

url1 = "https://www.vgchartz.com/games/games.php?name=&keyword=&console=&region=All&developer=&publisher=&goty_year=&genre="
url2 = "&boxart=Both&banner=Both&ownership=Both&showmultiplat=No&results=10000&order=Sales&showtotalsales=1&showpublisher=1&showvgchartzscore=0&showvgchartzscore=1shownasales=1&showdeveloper=1&showcriticscore=1&showpalsales=1&showreleasedate=1&showuserscore=1&showjapansales=1&showlastupdate=1&showothersales=1&showshipped=1"

genres = ["Action", "Action-Adventure", "Adventure", "Board Game", "Education", "Fighting", "Misc", "MMO", "Music", "Party", "Platform", "Puzzle", "Racing", "Role-Playing", "Sandbox", "Shooter", "Simulation", "Sports", "Strategy", "Visual Novel"]

print("Initializing driver")
driver_path = "scripts/chromedriver.exe" # Replace with path to your actual chromedriver
options = Options()
options.add_argument("--headless=new")
options.add_argument("--blink-settings=imagesEnabled=false")
print("Starting Chrome webdriver")
driver = webdriver.Chrome(executable_path=driver_path, options=options)
print("Started")

for genre in genres:
    print("Connecting to VGChartz Page for " + genre)
    url = url1 + genre.replace(' ', '+') + url2
    driver.get(url)
    driver.implicitly_wait(30)
    print("Driver got page content")

    html_content = driver.page_source
    print("Starting soup parser")
    soup = BeautifulSoup(html_content, 'html.parser')
    table = soup.find('table')
    rows = table.find_all('tr')

    print("Building data array from page...")

    data = []
    for row in rows:
        cols = row.find_all('td')
        cols = [col.text.strip() for col in cols]
        data.append(cols)

    output = "data/raw/" + genre.replace(' ', '_') + '.csv'
    print("Writing to file " + output)
    with open(output, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerows(data)

    print("File created!")

driver.quit()
