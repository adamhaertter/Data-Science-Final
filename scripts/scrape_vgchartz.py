from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
import csv

url1 = "https://www.vgchartz.com/games/games.php?name=&keyword=&console=&region=All&developer=&publisher=&goty_year=&genre="
url2 = "&boxart=Both&banner=Both&ownership=Both&showmultiplat=No&results=10000&order=Sales&showtotalsales=1&showpublisher=1&showvgchartzscore=0&showvgchartzscore=1&shownasales=1&showdeveloper=1&showcriticscore=1&showpalsales=1&showreleasedate=1&showuserscore=1&showjapansales=1&showlastupdate=1&showothersales=1&showshipped=1"

#genres = ["Action", "Action-Adventure", "Adventure", "Board Game", "Education", "Fighting", "Misc", "MMO", "Music", "Party", "Platform", "Puzzle", "Racing", "Role-Playing", "Sandbox", "Shooter", "Simulation", "Sports", "Strategy", "Visual Novel"]
genres = ["Action"]

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
    print("Driver got page content")

    table_xpath = '/html/body/div[4]/div/div[2]/table/tbody/tr/td/div/div[2]/table[1]'  # Replace with the XPath of your table
    table_element = WebDriverWait(driver, 5).until(
        EC.presence_of_element_located((By.XPATH, table_xpath))
    )

    table_html = table_element.get_attribute('outerHTML')
    soup = BeautifulSoup(table_html, 'html.parser')
    rows = soup.find_all('tr')

    print("Building data array from page...")

    data = []
    for i, row in enumerate(rows):
        if(i < 3):
            cols = row.find_all('th')
        else:
            cols = row.find_all('td')
        row_data = []
        for col in cols:
            if col.find('img') is not None:
                row_data.append(col.find('img').get('alt'))
            else:
                row_data.append(col.text.strip())
        if(i == 2):            
            row_data.insert(1, "Box Art")
            print(row_data)
        data.append(row_data)

    output = "data/raw/" + genre.replace(' ', '_') + '.csv'
    print("Writing to file " + output)
    with open(output, 'w', encoding='utf-8', newline='') as file:
        writer = csv.writer(file)
        writer.writerows(data)

    print("File created!")

driver.quit()
