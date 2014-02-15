//
//  constants.h
//  SchoolInterface
//
//  Created by Jason McDermott on 16/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#ifndef SchoolInterface_constants_h
#define SchoolInterface_constants_h

#define PI 3.14159265359
#define NUM_RINGS 10


// BLE Device constants
#define NUM_PULSE_BYTES 3
#define MAX_INACTIVITY 8
#define SCAN_TIME 3


const char *placenames[] = {
    "Abilene",
    "Addison",
    "Akron",
    "Alameda",
    "Alamogordo",
    "Albany",
    "Albuquerque",
    "Alexandria",
    "Alhambra",
    "Aliso-Viejo",
    "Allen",
    "Allentown",
    "Alpharetta",
    "Altamonte-Springs",
    "Altoona",
    "Amarillo",
    "Ames",
    "Anaheim",
    "Anchorage",
    "Anderson",
    "Ankeny",
    "Ann-Arbor",
    "Annapolis",
    "Antioch",
    "Apopka",
    "Apple-Valley",
    "Appleton",
    "Arcadia",
    "Arlington",
    "Arlington-Heights",
    "Arvada",
    "Asheville",
    "Atlanta",
    "Atlantic-City",
    "Attleboro",
    "Auburn",
    "Aurora",
    "Austin",
    "Avondale",
    "Azusa",
    "Bakersfield",
    "Baldwin-Park",
    "Baltimore",
    "Barnstable-Town",
    "Bartlesville",
    "Bartlett",
    "Baton-Rouge",
    "Battle-Creek",
    "Bayonne",
    "Baytown",
    "Beaumont",
    "Beavercreek",
    "Beaverton",
    "Bedford",
    "Bell",
    "Bell-Gardens",
    "Belleville",
    "Bellevue",
    "Bellflower",
    "Bellingham",
    "Beloit",
    "Bend",
    "Bentonville",
    "Berkeley",
    "Berwyn",
    "Bethlehem",
    "Beverly",
    "Billings",
    "Biloxi",
    "Binghamton",
    "Birmingham",
    "Bismarck",
    "Blacksburg",
    "Blaine",
    "Bloomington",
    "Blue-Springs",
    "Boca-Raton",
    "Boise-City",
    "Bolingbrook",
    "Bonita-Springs",
    "Bossier-City",
    "Boston",
    "Boulder",
    "Bountiful",
    "Bowie",
    "Bowling-Green",
    "Boynton-Beach",
    "Bozeman",
    "Bradenton",
    "Brea",
    "Brentwood",
    "Bridgeport",
    "Bristol",
    "Brockton",
    "Broken-Arrow",
    "Brookfield",
    "Brooklyn-Park",
    "Broomfield",
    "Brownsville",
    "Bryan",
    "Buckeye",
    "Buena-Park",
    "Buffalo",
    "Buffalo-Grove",
    "Bullhead-City",
    "Burbank",
    "Burleson",
    "Burlington",
    "Burnsville",
    "Caldwell",
    "Calexico",
    "Calumet-City",
    "Camarillo",
    "Cambridge",
    "Camden",
    "Campbell",
    "Canton",
    "Cape-Coral",
    "Cape-Girardeau",
    "Carlsbad",
    "Carmel",
    "Carol-Stream",
    "Carpentersville",
    "Carrollton",
    "Carson",
    "Carson-City",
    "Cary",
    "Casa-Grande",
    "Casper",
    "Castle-Rock",
    "Cathedral-City",
    "Cedar-Falls",
    "Cedar-Hill",
    "Cedar-Park",
    "Cedar-Rapids",
    "Centennial",
    "Ceres",
    "Cerritos",
    "Champaign",
    "Chandler",
    "Chapel-Hill",
    "Charleston",
    "Charlotte",
    "Charlottesville",
    "Chattanooga",
    "Chelsea",
    "Chesapeake",
    "Chester",
    "Chesterfield",
    "Cheyenne",
    "Chicago",
    "Chico",
    "Chicopee",
    "Chino",
    "Chino-Hills",
    "Chula-Vista",
    "Cicero",
    "Cincinnati",
    "Citrus-Heights",
    "Claremont",
    "Clarksville",
    "Clearwater",
    "Cleveland",
    "Cleveland-Heights",
    "Clifton",
    "Clovis",
    "Coachella",
    "Coconut-Creek",
    "Coeur-d-Alene",
    "College-Station",
    "Collierville",
    "Colorado-Springs",
    "Colton",
    "Columbia",
    "Columbus",
    "Commerce-City",
    "Compton",
    "Concord",
    "Conroe",
    "Conway",
    "Coon-Rapids",
    "Coppell",
    "Coral-Gables",
    "Coral-Springs",
    "Corona",
    "Corpus-Christi",
    "Corvallis",
    "Costa-Mesa",
    "Cottonwood-Heights",
    "Council-Bluffs",
    "Covina",
    "Covington",
    "Cranston",
    "Crystal-Lake",
    "Culver-City",
    "Cupertino",
    "Cuyahoga-Falls",
    "Cypress",
    "Dallas",
    "Daly-City",
    "Dana-Point",
    "Danbury",
    "Danville",
    "Davenport",
    "Davie",
    "Davis",
    "Dayton",
    "Daytona-Beach",
    "DeKalb",
    "DeSoto",
    "Dearborn",
    "Dearborn-Heights",
    "Decatur",
    "Deerfield-Beach",
    "Del-Rio",
    "Delano",
    "Delray-Beach",
    "Deltona",
    "Denton",
    "Denver",
    "Des-Moines",
    "Des-Plaines",
    "Detroit",
    "Diamond-Bar",
    "Dothan",
    "Dover",
    "Downers-Grove",
    "Downey",
    "Draper",
    "Dublin",
    "Dubuque",
    "Duluth",
    "Duncanville",
    "Dunedin",
    "Durham",
    "Eagan",
    "East-Lansing",
    "East-Orange",
    "East-Point",
    "East-Providence",
    "Eau-Claire",
    "Eden-Prairie",
    "Edina",
    "Edinburg",
    "Edmond",
    "Edmonds",
    "El-Cajon",
    "El-Centro",
    "El-Monte",
    "El-Paso",
    "Elgin",
    "Elizabeth",
    "Elk-Grove",
    "Elkhart",
    "Elmhurst",
    "Elyria",
    "Encinitas",
    "Enid",
    "Erie",
    "Escondido",
    "Euclid",
    "Eugene",
    "Euless",
    "Evanston",
    "Evansville",
    "Everett",
    "Fairfield",
    "Fall-River",
    "Fargo",
    "Farmington",
    "Farmington-Hills",
    "Fayetteville",
    "Federal-Way",
    "Findlay",
    "Fishers",
    "Fitchburg",
    "Flagstaff",
    "Flint",
    "Florence",
    "Florissant",
    "Flower-Mound",
    "Folsom",
    "Fond-du-Lac",
    "Fontana",
    "Fort-Collins",
    "Fort-Lauderdale",
    "Fort-Lee",
    "Fort-Myers",
    "Fort-Pierce",
    "Fort-Smith",
    "Fort-Wayne",
    "Fort-Worth",
    "Fountain-Valley",
    "Franklin",
    "Frederick",
    "Freeport",
    "Fremont",
    "Fresno",
    "Frisco",
    "Fullerton",
    "Gadsden",
    "Gainesville",
    "Gaithersburg",
    "Galveston",
    "Garden-Grove",
    "Gardena",
    "Garland",
    "Gary",
    "Gastonia",
    "Georgetown",
    "Germantown",
    "Gilbert",
    "Gilroy",
    "Glendale",
    "Glendora",
    "Glenview",
    "Goldsboro",
    "Goodyear",
    "Goose-Creek",
    "Grand-Forks",
    "Grand-Island",
    "Grand-Junction",
    "Grand-Prairie",
    "Grand-Rapids",
    "Grapevine",
    "Great-Falls",
    "Greeley",
    "Green-Bay",
    "Greenfield",
    "Greensboro",
    "Greenville",
    "Greenwood",
    "Gresham",
    "Gulfport",
    "Hackensack",
    "Hagerstown",
    "Hallandale-Beach",
    "Haltom-City",
    "Hamilton",
    "Hammond",
    "Hampton",
    "Hanford",
    "Hanover-Park",
    "Harlingen",
    "Harrisburg",
    "Harrisonburg",
    "Hartford",
    "Hattiesburg",
    "Haverhill",
    "Hawthorne",
    "Hayward",
    "Hemet",
    "Hempstead",
    "Henderson",
    "Hendersonville",
    "Hesperia",
    "Hialeah",
    "Hickory",
    "High-Point",
    "Highland",
    "Hillsboro",
    "Hoboken",
    "Hoffman-Estates",
    "Hollywood",
    "Holyoke",
    "Homestead",
    "Honolulu",
    "Hoover",
    "Hot-Springs",
    "Houston",
    "Huber-Heights",
    "Huntersville",
    "Huntington",
    "Huntington-Beach",
    "Huntington-Park",
    "Huntsville",
    "Hurst",
    "Hutchinson",
    "Idaho-Falls",
    "Independence",
    "Indianapolis",
    "Indio",
    "Inglewood",
    "Iowa-City",
    "Irvine",
    "Irving",
    "Jackson",
    "Jacksonville",
    "Janesville",
    "Jefferson-City",
    "Jersey-City",
    "Johns-Creek",
    "Johnson-City",
    "Joliet",
    "Jonesboro",
    "Joplin",
    "Jupiter",
    "Kalamazoo",
    "Kannapolis",
    "Kansas-City",
    "Kearny",
    "Keizer",
    "Keller",
    "Kenner",
    "Kennewick",
    "Kenosha",
    "Kent",
    "Kentwood",
    "Kettering",
    "Killeen",
    "Kingsport",
    "Kirkland",
    "Kissimmee",
    "Knoxville",
    "Kokomo",
    "La-Crosse",
    "La-Habra",
    "La-Mesa",
    "La-Mirada",
    "La-Puente",
    "La-Quinta",
    "Lacey",
    "Lafayette",
    "Laguna-Niguel",
    "Lake-Charles",
    "Lake-Elsinore",
    "Lake-Forest",
    "Lake-Havasu-City",
    "Lake-Oswego",
    "Lake-Worth",
    "Lakeland",
    "Lakeville",
    "Lakewood",
    "Lancaster",
    "Lansing",
    "Laredo",
    "Largo",
    "Las-Cruces",
    "Las-Vegas",
    "Lauderhill",
    "Lawrence",
    "Lawton",
    "Layton",
    "League-City",
    "Lee-s-Summit",
    "Leesburg",
    "Lehi",
    "Lenexa",
    "Leominster",
    "Lewisville",
    "Lexington-Fayette",
    "Lima",
    "Lincoln",
    "Linden",
    "Little-Rock",
    "Littleton",
    "Livermore",
    "Livonia",
    "Lodi",
    "Logan",
    "Lombard",
    "Lompoc",
    "Long-Beach",
    "Longmont",
    "Longview",
    "Lorain",
    "Los-Angeles",
    "Loveland",
    "Lowell",
    "Lubbock",
    "Lynchburg",
    "Lynn",
    "Lynwood",
    "Macon",
    "Madera",
    "Madison",
    "Malden",
    "Manassas",
    "Manchester",
    "Manhattan",
    "Manhattan-Beach",
    "Mankato",
    "Mansfield",
    "Manteca",
    "Maple-Grove",
    "Maplewood",
    "Margate",
    "Maricopa",
    "Marietta",
    "Marion",
    "Marlborough",
    "Martinez",
    "McAllen",
    "McKinney",
    "Medford",
    "Melbourne",
    "Memphis",
    "Menifee",
    "Mentor",
    "Merced",
    "Meriden",
    "Meridian",
    "Mesa",
    "Mesquite",
    "Methuen",
    "Miami",
    "Miami-Beach",
    "Miami-Gardens",
    "Middletown",
    "Midland",
    "Midwest-City",
    "Milford",
    "Milpitas",
    "Milwaukee",
    "Minneapolis",
    "Minnetonka",
    "Minot",
    "Miramar",
    "Mishawaka",
    "Mission",
    "Mission-Viejo",
    "Missoula",
    "Missouri-City",
    "Mobile",
    "Modesto",
    "Moline",
    "Monroe",
    "Monrovia",
    "Montclair",
    "Montebello",
    "Monterey-Park",
    "Montgomery",
    "Moore",
    "Moorhead",
    "Moorpark",
    "Moreno-Valley",
    "Morgan-Hill",
    "Mount-Pleasant",
    "Mount-Prospect",
    "Mount-Vernon",
    "Mountain-View",
    "Muncie",
    "Murfreesboro",
    "Murray",
    "Murrieta",
    "Muskegon",
    "Muskogee",
    "Nampa",
    "Napa",
    "Naperville",
    "Nashua",
    "Nashville-Davidson",
    "National-City",
    "New-Albany",
    "New-Bedford",
    "New-Berlin",
    "New-Braunfels",
    "New-Britain",
    "New-Brunswick",
    "New-Haven",
    "New-Orleans",
    "New-Rochelle",
    "New-York",
    "Newark",
    "Newport-Beach",
    "Newport-News",
    "Newton",
    "Niagara-Falls",
    "Noblesville",
    "Norfolk",
    "Normal",
    "Norman",
    "North-Charleston",
    "North-Las-Vegas",
    "North-Lauderdale",
    "North-Little-Rock",
    "North-Miami",
    "North-Miami-Beach",
    "North-Port",
    "North-Richland-Hills",
    "Norwalk",
    "Norwich",
    "Novato",
    "Novi",
    "O-Fallon",
    "Oak-Lawn",
    "Oak-Park",
    "Oakland",
    "Oakland-Park",
    "Ocala",
    "Oceanside",
    "Odessa",
    "Ogden",
    "Oklahoma-City",
    "Olathe",
    "Olympia",
    "Omaha",
    "Ontario",
    "Orange",
    "Orem",
    "Orland-Park",
    "Orlando",
    "Ormond-Beach",
    "Oro-Valley",
    "Oshkosh",
    "Overland-Park",
    "Owensboro",
    "Oxnard",
    "Pacifica",
    "Palatine",
    "Palm-Bay",
    "Palm-Beach-Gardens",
    "Palm-Coast",
    "Palm-Desert",
    "Palm-Springs",
    "Palmdale",
    "Palo-Alto",
    "Panama-City",
    "Paramount",
    "Park-Ridge",
    "Parker",
    "Parma",
    "Pasadena",
    "Pasco",
    "Passaic",
    "Paterson",
    "Pawtucket",
    "Peabody",
    "Pearland",
    "Pembroke-Pines",
    "Pensacola",
    "Peoria",
    "Perris",
    "Perth-Amboy",
    "Petaluma",
    "Pflugerville",
    "Pharr",
    "Philadelphia",
    "Phoenix",
    "Pico-Rivera",
    "Pine-Bluff",
    "Pinellas-Park",
    "Pittsburg",
    "Pittsburgh",
    "Pittsfield",
    "Placentia",
    "Plainfield",
    "Plano",
    "Plantation",
    "Pleasanton",
    "Plymouth",
    "Pocatello",
    "Pomona",
    "Pompano-Beach",
    "Pontiac",
    "Port-Arthur",
    "Port-Orange",
    "Port-St-Lucie",
    "Portage",
    "Porterville",
    "Portland",
    "Portsmouth",
    "Poway",
    "Prescott",
    "Prescott-Valley",
    "Providence",
    "Provo",
    "Pueblo",
    "Puyallup",
    "Quincy",
    "Racine",
    "Raleigh",
    "Rancho-Cordova",
    "Rancho-Cucamonga",
    "Rancho-Palos-Verdes",
    "Rancho-Santa-Margarita",
    "Rapid-City",
    "Reading",
    "Redding",
    "Redlands",
    "Redmond",
    "Redondo-Beach",
    "Redwood-City",
    "Reno",
    "Renton",
    "Revere",
    "Rialto",
    "Richardson",
    "Richland",
    "Richmond",
    "Rio-Rancho",
    "Riverside",
    "Riverton",
    "Riviera-Beach",
    "Roanoke",
    "Rochester",
    "Rochester-Hills",
    "Rock-Hill",
    "Rock-Island",
    "Rockford",
    "Rocklin",
    "Rockville",
    "Rockwall",
    "Rocky-Mount",
    "Rogers",
    "Rohnert-Park",
    "Rome",
    "Romeoville",
    "Rosemead",
    "Roseville",
    "Roswell",
    "Round-Rock",
    "Rowlett",
    "Roy",
    "Royal-Oak",
    "Sacramento",
    "Saginaw",
    "Salem",
    "Salina",
    "Salinas",
    "Salt-Lake-City",
    "Sammamish",
    "San-Angelo",
    "San-Antonio",
    "San-Bernardino",
    "San-Bruno",
    "San-Buenaventura-(Ventura)",
    "San-Clemente",
    "San-Diego",
    "San-Francisco",
    "San-Gabriel",
    "San-Jacinto",
    "San-Jose",
    "San-Leandro",
    "San-Luis-Obispo",
    "San-Marcos",
    "San-Mateo",
    "San-Rafael",
    "San-Ramon",
    "Sandy",
    "Sandy-Springs",
    "Sanford",
    "Santa-Ana",
    "Santa-Barbara",
    "Santa-Clara",
    "Santa-Clarita",
    "Santa-Cruz",
    "Santa-Fe",
    "Santa-Maria",
    "Santa-Monica",
    "Santa-Rosa",
    "Santee",
    "Sarasota",
    "Savannah",
    "Sayreville",
    "Schaumburg",
    "Schenectady",
    "Scottsdale",
    "Scranton",
    "Seattle",
    "Shawnee",
    "Sheboygan",
    "Shelton",
    "Sherman",
    "Shoreline",
    "Shreveport",
    "Sierra-Vista",
    "Simi-Valley",
    "Sioux-City",
    "Sioux-Falls",
    "Skokie",
    "Smyrna",
    "Somerville",
    "South-Bend",
    "South-Gate",
    "South-Jordan",
    "South-San-Francisco",
    "Southaven",
    "Southfield",
    "Sparks",
    "Spartanburg",
    "Spokane",
    "Spokane-Valley",
    "Springdale",
    "Springfield",
    "St-Charles",
    "St-Clair-Shores",
    "St-Cloud",
    "St-George",
    "St-Joseph",
    "St-Louis",
    "St-Louis-Park",
    "St-Paul",
    "St-Peters",
    "St-Petersburg",
    "Stamford",
    "Stanton",
    "State-College",
    "Sterling-Heights",
    "Stillwater",
    "Stockton",
    "Streamwood",
    "Strongsville",
    "Suffolk",
    "Sugar-Land",
    "Summerville",
    "Sumter",
    "Sunnyvale",
    "Sunrise",
    "Surprise",
    "Syracuse",
    "Tacoma",
    "Tallahassee",
    "Tamarac",
    "Tampa",
    "Taunton",
    "Taylor",
    "Taylorsville",
    "Temecula",
    "Tempe",
    "Temple",
    "Temple-City",
    "Terre-Haute",
    "Texarkana",
    "Texas-City",
    "The-Colony",
    "Thornton",
    "Thousand-Oaks",
    "Tigard",
    "Tinley-Park",
    "Titusville",
    "Toledo",
    "Topeka",
    "Torrance",
    "Torrington",
    "Tracy",
    "Trenton",
    "Troy",
    "Tucson",
    "Tulare",
    "Tulsa",
    "Tupelo",
    "Turlock",
    "Tuscaloosa",
    "Tustin",
    "Twin-Falls",
    "Tyler",
    "Union-City",
    "University-City",
    "Upland",
    "Urbana",
    "Urbandale",
    "Utica",
    "Vacaville",
    "Valdosta",
    "Vallejo",
    "Valley-Stream",
    "Vancouver",
    "Victoria",
    "Victorville",
    "Vineland",
    "Virginia-Beach",
    "Visalia",
    "Vista",
    "Waco",
    "Walnut-Creek",
    "Waltham",
    "Warner-Robins",
    "Warren",
    "Warwick",
    "Washington",
    "Waterbury",
    "Waterloo",
    "Watsonville",
    "Waukegan",
    "Waukesha",
    "Wausau",
    "Wauwatosa",
    "Wellington",
    "West-Allis",
    "West-Covina",
    "West-Des-Moines",
    "West-Haven",
    "West-Hollywood",
    "West-Jordan",
    "West-New-York",
    "West-Palm-Beach",
    "West-Sacramento",
    "West-Valley-City",
    "Westerville",
    "Westfield",
    "Westland",
    "Westminster",
    "Weston",
    "Wheaton",
    "Wheeling",
    "White-Plains",
    "Whittier",
    "Wichita",
    "Wichita-Falls",
    "Wilkes-Barre",
    "Wilmington",
    "Wilson",
    "Winston-Salem",
    "Woburn",
    "Woodbury",
    "Woodland",
    "Woonsocket",
    "Worcester",
    "Wylie",
    "Wyoming",
    "Yakima",
    "Yonkers",
    "Yorba-Linda",
    "York",
    "Youngstown",
    "Yuba-City",
    "Yucaipa",
    "Yuma"
};



#endif
