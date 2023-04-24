from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
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
    #driver.implicitly_wait(30)
    print("Driver got page content")

    # html_content = driver.page_source
    # print("Starting soup parser")
    # soup = BeautifulSoup(html_content, 'html.parser')
    # table = soup.find('table')

    # Wait for the table element to be present
    table_xpath = '/html/body/div[4]/div/div[2]/table/tbody/tr/td/div/div[2]/table[1]'  # Replace with the XPath of your table
    table_element = WebDriverWait(driver, 30).until(
        EC.presence_of_element_located((By.XPATH, table_xpath))
    )

    # Get the outerHTML of the table element
    table_html = table_element.get_attribute('outerHTML')

    # Parse the HTML using BeautifulSoup
    soup = BeautifulSoup(table_html, 'html.parser')

    rows = soup.find_all('tr')

    print("Building data array from page...")

    data = []
    for row in rows:
        cols = row.find_all('td')
        cols = [col.text.strip() for col in cols]
        data.append(cols)

    output = "data/raw/" + genre.replace(' ', '_') + '.csv'
    print("Writing to file " + output)
    with open(output, 'w', encoding='utf-8', newline='') as file:
        writer = csv.writer(file)
        writer.writerows(data)

    print("File created!")

driver.quit()
