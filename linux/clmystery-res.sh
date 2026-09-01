
grep -i 'clue' crimescene

CLUE: Footage from an ATM security camera is blurry but shows that the perpetrator is a tall male, at least 6.
CLUE: Found a wallet believed to belong to the killer: no ID, just loose change, and membership cards for AAA, Delta SkyMiles, the local library, and the Museum of Bash History. The cards are totally untraceable and have no name, for some reason.
CLUE: Questioned the barista at the local coffee shop. He said a woman left right before they heard the shots. The name on her latte was Annabel, she had blond spiky hair and a New Zealand accent.

Male tall 6,
Wallet, merber card -> AAA, Delta SkyMiles, the local library, and the Museum of Bash History.
Woman -> Annabel, she had blond spiky hair and a New Zealand accent.she left right before they heard the shots

grep -i 'Annabel' people    
Annabel Sun             F       26      Hart Place, line 40
Oluwasegun Annabel      M       37      Mattapan Street, line 173
Annabel Church          F       38      Buckingham Place, line 179
Annabel Fuglsang        M       40      Haley Street, line 176


❯ grep -i -C 3 'Annabel' vehicles 
License Plate 9R7TTGF

Make: Volkswagen
Color: Yellow
Owner: Oluwasegun Annabel
Height: 5'1"
Weight: 240 lbs

--
License Plate L2E48EF
Make: BMW
Color: Orange
Owner: Annabel Church
Height: 5'5"
Weight: 201 lbs

--
License Plate 0O27BTD
Make: Fiat
Color: Yellow
Owner: Annabel Sun
Height: 5'0"
Weight: 232 lbs

--
License Plate 20VVU2P
Make: Mazda
Color: Pink
Owner: Annabel Fuglsang
Height: 5'11"'
Weight: 241 lbs


------------------------------

grep -i -r 'Church' *
interviews/interview-699607:Interviewed Ms. Church at 2:04 pm.  Witness stated that she did not see anyone she could identify as the shooter, that she ran away as soon as the shots were fired.

❯ cat interview-699607      
Interviewed Ms. Church at 2:04 pm.  Witness stated that she did not see anyone she could identify as the shooter, that she ran away as soon as the shots were fired.

However, she reports seeing the car that fled the scene.  Describes it as a blue Honda, with a license plate that starts with "L337" and ends with "9"

grep -i -C 4 'L337' vehicles | grep '9$' -C 4 | grep 'Honda' -C 4 | grep 'Blue' -C 2

License Plate L337QE9
Make: Honda
Color: Blue
Owner: Erika Owens
Height: 6'5"
--
License Plate L337539
Make: Honda
Color: Blue
Owner: Aron Pilhofer
Height: 5'3"
--
License Plate L337369
Make: Honda
Color: Blue
Owner: Heather Billings
Height: 5'2"
--
License Plate L337DV9
Make: Honda
Color: Blue
Owner: Joe Germuska
Height: 6'2"
--
License Plate L3375A9
Make: Honda
Color: Blue
Owner: Jeremy Bowers
Height: 6'1"
--
License Plate L337WR9
Make: Honda
Color: Blue
Owner: Jacqui Maher
Height: 6'2"

o con una mejor consulta usando awk

❯ awk -v RS="" '/L337.*9/ && /Honda/ && /Blue/ && /Height: [6-9]/ {print $0 "\n--"}' vehicles 
License Plate L337QE9
Make: Honda
Color: Blue
Owner: Erika Owens
Height: 6'5"
Weight: 220 lbs
--
License Plate L337DV9
Make: Honda
Color: Blue
Owner: Joe Germuska
Height: 6'2"
Weight: 164 lbs
--
License Plate L3375A9
Make: Honda
Color: Blue
Owner: Jeremy Bowers
Height: 6'1"
Weight: 204 lbs
--
License Plate L337WR9
Make: Honda
Color: Blue
Owner: Jacqui Maher
Height: 6'2"
Weight: 130 lbs


Jacqui son Erika mujeres asi que .. nos quedamos con estos

License Plate L337DV9
Make: Honda
Color: Blue
Owner: Joe Germuska
Height: 6'2"
Weight: 164 lbs
--
License Plate L3375A9
Make: Honda
Color: Blue
Owner: Jeremy Bowers
Height: 6'1"
Weight: 204 lbs


clmystery/mystery/memberships on  master [?] 
❯ grep -i -r 'Jeremy Bowers' *
AAA:Jeremy Bowers
Delta_SkyMiles:Jeremy Bowers
Museum_of_Bash_History:Jeremy Bowers
Terminal_City_Library:Jeremy Bowers

Esto concuerda que es Jeremy Bowers



