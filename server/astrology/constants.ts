export type Planet = 'Sun' | 'Moon' | 'Mars' | 'Mercury' | 'Jupiter' | 'Venus' | 'Saturn' | 'Rahu' | 'Ketu';

export type ZodiacSign = 
  | 'Aries' | 'Taurus' | 'Gemini' | 'Cancer' 
  | 'Leo' | 'Virgo' | 'Libra' | 'Scorpio' 
  | 'Sagittarius' | 'Capricorn' | 'Aquarius' | 'Pisces';

export type Nakshatra = 
  | 'Ashwini' | 'Bharani' | 'Krittika' | 'Rohini' | 'Mrigashira' | 'Ardra' | 'Punarvasu'
  | 'Pushya' | 'Ashlesha' | 'Magha' | 'Purva Phalguni' | 'Uttara Phalguni' | 'Hasta'
  | 'Chitra' | 'Swati' | 'Vishakha' | 'Anuradha' | 'Jyeshtha' | 'Mula' | 'Purva Ashadha'
  | 'Uttara Ashadha' | 'Shravana' | 'Dhanishta' | 'Shatabhisha' | 'Purva Bhadrapada'
  | 'Uttara Bhadrapada' | 'Revati';

export type Direction = 'East' | 'West' | 'North' | 'South' | 'North-East' | 'North-West' | 'South-East' | 'South-West';

export type Weekday = 'Sunday' | 'Monday' | 'Tuesday' | 'Wednesday' | 'Thursday' | 'Friday' | 'Saturday';

export const WEEKDAY_LORDS: Record<Weekday, Planet> = {
  Sunday: 'Sun',
  Monday: 'Moon',
  Tuesday: 'Mars',
  Wednesday: 'Mercury',
  Thursday: 'Jupiter',
  Friday: 'Venus',
  Saturday: 'Saturn',
};

export const NAKSHATRA_LIST: Nakshatra[] = [
  'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra', 'Punarvasu',
  'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni', 'Hasta',
  'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha', 'Mula', 'Purva Ashadha',
  'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha', 'Purva Bhadrapada',
  'Uttara Bhadrapada', 'Revati',
];

export const NAKSHATRA_LORDS: Record<Nakshatra, Planet> = {
  'Ashwini': 'Ketu',
  'Bharani': 'Venus',
  'Krittika': 'Sun',
  'Rohini': 'Moon',
  'Mrigashira': 'Mars',
  'Ardra': 'Rahu',
  'Punarvasu': 'Jupiter',
  'Pushya': 'Saturn',
  'Ashlesha': 'Mercury',
  'Magha': 'Ketu',
  'Purva Phalguni': 'Venus',
  'Uttara Phalguni': 'Sun',
  'Hasta': 'Moon',
  'Chitra': 'Mars',
  'Swati': 'Rahu',
  'Vishakha': 'Jupiter',
  'Anuradha': 'Saturn',
  'Jyeshtha': 'Mercury',
  'Mula': 'Ketu',
  'Purva Ashadha': 'Venus',
  'Uttara Ashadha': 'Sun',
  'Shravana': 'Moon',
  'Dhanishta': 'Mars',
  'Shatabhisha': 'Rahu',
  'Purva Bhadrapada': 'Jupiter',
  'Uttara Bhadrapada': 'Saturn',
  'Revati': 'Mercury',
};

export const ZODIAC_SIGNS: ZodiacSign[] = [
  'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
  'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
];

export const SIGN_LORDS: Record<ZodiacSign, Planet> = {
  'Aries': 'Mars',
  'Taurus': 'Venus',
  'Gemini': 'Mercury',
  'Cancer': 'Moon',
  'Leo': 'Sun',
  'Virgo': 'Mercury',
  'Libra': 'Venus',
  'Scorpio': 'Mars',
  'Sagittarius': 'Jupiter',
  'Capricorn': 'Saturn',
  'Aquarius': 'Saturn',
  'Pisces': 'Jupiter',
};

export const PLANET_EXALTATION: Record<Planet, ZodiacSign | null> = {
  'Sun': 'Aries',
  'Moon': 'Taurus',
  'Mars': 'Capricorn',
  'Mercury': 'Virgo',
  'Jupiter': 'Cancer',
  'Venus': 'Pisces',
  'Saturn': 'Libra',
  'Rahu': 'Gemini',
  'Ketu': 'Sagittarius',
};

export const PLANET_DEBILITATION: Record<Planet, ZodiacSign | null> = {
  'Sun': 'Libra',
  'Moon': 'Scorpio',
  'Mars': 'Cancer',
  'Mercury': 'Pisces',
  'Jupiter': 'Capricorn',
  'Venus': 'Virgo',
  'Saturn': 'Aries',
  'Rahu': 'Sagittarius',
  'Ketu': 'Gemini',
};

export const PLANET_OWN_SIGNS: Record<Planet, ZodiacSign[]> = {
  'Sun': ['Leo'],
  'Moon': ['Cancer'],
  'Mars': ['Aries', 'Scorpio'],
  'Mercury': ['Gemini', 'Virgo'],
  'Jupiter': ['Sagittarius', 'Pisces'],
  'Venus': ['Taurus', 'Libra'],
  'Saturn': ['Capricorn', 'Aquarius'],
  'Rahu': ['Aquarius'],
  'Ketu': ['Scorpio'],
};

export const PLANET_FRIENDS: Record<Planet, Planet[]> = {
  'Sun': ['Moon', 'Mars', 'Jupiter'],
  'Moon': ['Sun', 'Mercury'],
  'Mars': ['Sun', 'Moon', 'Jupiter'],
  'Mercury': ['Sun', 'Venus'],
  'Jupiter': ['Sun', 'Moon', 'Mars'],
  'Venus': ['Mercury', 'Saturn'],
  'Saturn': ['Mercury', 'Venus'],
  'Rahu': ['Mercury', 'Venus', 'Saturn'],
  'Ketu': ['Mars', 'Venus', 'Saturn'],
};

export const PLANET_ENEMIES: Record<Planet, Planet[]> = {
  'Sun': ['Venus', 'Saturn'],
  'Moon': [],
  'Mars': ['Mercury'],
  'Mercury': ['Moon'],
  'Jupiter': ['Mercury', 'Venus'],
  'Venus': ['Sun', 'Moon'],
  'Saturn': ['Sun', 'Moon', 'Mars'],
  'Rahu': ['Sun', 'Moon', 'Mars'],
  'Ketu': ['Sun', 'Moon'],
};

export const PLANET_LUCKY_NUMBER: Record<Planet, number> = {
  'Sun': 1,
  'Moon': 2,
  'Jupiter': 3,
  'Rahu': 4,
  'Mercury': 5,
  'Venus': 6,
  'Ketu': 7,
  'Saturn': 8,
  'Mars': 9,
};

export const PLANET_DIRECTION: Record<Planet, Direction> = {
  'Sun': 'East',
  'Moon': 'North-West',
  'Mars': 'South',
  'Mercury': 'North',
  'Jupiter': 'North-East',
  'Venus': 'South-East',
  'Saturn': 'West',
  'Rahu': 'South-West',
  'Ketu': 'North-East',
};

export const PLANET_COLOR: Record<Planet, { name: string; nameHi: string; hex: string }> = {
  'Sun': { name: 'Gold', nameHi: 'सुनहरा', hex: '#FFD700' },
  'Moon': { name: 'White', nameHi: 'सफ़ेद', hex: '#F5F5F5' },
  'Mars': { name: 'Red', nameHi: 'लाल', hex: '#E53935' },
  'Mercury': { name: 'Green', nameHi: 'हरा', hex: '#43A047' },
  'Jupiter': { name: 'Yellow', nameHi: 'पीला', hex: '#FDD835' },
  'Venus': { name: 'Pink', nameHi: 'गुलाबी', hex: '#EC407A' },
  'Saturn': { name: 'Navy', nameHi: 'गहरा नीला', hex: '#1A237E' },
  'Rahu': { name: 'Smoky Grey', nameHi: 'धुँआ-सा', hex: '#607D8B' },
  'Ketu': { name: 'Maroon', nameHi: 'मैरून', hex: '#6D4C41' },
};

export const PLANET_MANTRA: Record<Planet, { sanskrit: string; meaning: string }> = {
  'Sun': { sanskrit: 'Om Suryaya Namah', meaning: 'I lead with clarity.' },
  'Moon': { sanskrit: 'Om Som Somaya Namah', meaning: 'I stay calm and steady.' },
  'Mars': { sanskrit: 'Om Mangalaya Namah', meaning: 'I act with courage.' },
  'Mercury': { sanskrit: 'Om Budhaya Namah', meaning: 'My mind is sharp and clear.' },
  'Jupiter': { sanskrit: 'Om Gurave Namah', meaning: 'I choose wisdom.' },
  'Venus': { sanskrit: 'Om Shukraya Namah', meaning: 'I attract harmony.' },
  'Saturn': { sanskrit: 'Om Sham Shanicharaya Namah', meaning: 'I build with patience.' },
  'Rahu': { sanskrit: 'Om Rahave Namah', meaning: 'I stay aware and focused.' },
  'Ketu': { sanskrit: 'Om Ketave Namah', meaning: 'I let go and trust.' },
};

export const CHALDEAN_ORDER: Planet[] = ['Saturn', 'Jupiter', 'Mars', 'Sun', 'Venus', 'Mercury', 'Moon'];

export const DIRECTION_HINDI: Record<Direction, string> = {
  'East': 'पूर्व',
  'West': 'पश्चिम',
  'North': 'उत्तर',
  'South': 'दक्षिण',
  'North-East': 'ईशान',
  'North-West': 'वायव्य',
  'South-East': 'आग्नेय',
  'South-West': 'नैऋत्य',
};

export const LAHIRI_AYANAMSA_J2000 = 23.856;
export const AYANAMSA_ANNUAL_PRECESSION = 50.29 / 3600;
