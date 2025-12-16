import {
  Planet,
  ZodiacSign,
  Nakshatra,
  Weekday,
  WEEKDAY_LORDS,
  NAKSHATRA_LIST,
  NAKSHATRA_LORDS,
  ZODIAC_SIGNS,
  SIGN_LORDS,
  PLANET_EXALTATION,
  PLANET_DEBILITATION,
  PLANET_OWN_SIGNS,
  PLANET_FRIENDS,
  PLANET_ENEMIES,
  PLANET_LUCKY_NUMBER,
  PLANET_DIRECTION,
  PLANET_COLOR,
  PLANET_MANTRA,
  CHALDEAN_ORDER,
  LAHIRI_AYANAMSA_J2000,
  AYANAMSA_ANNUAL_PRECESSION,
} from './constants';

export interface NatalChart {
  lagnaSign: ZodiacSign;
  moonSign: ZodiacSign;
  moonNakshatra: Nakshatra;
  moonNakshatraLord: Planet;
  sunSign: ZodiacSign;
  planetSigns: Record<Planet, ZodiacSign>;
  planetHouseFromLagna: Record<Planet, number>;
  natalStrength: Record<Planet, number>;
}

export interface DailyPanchang {
  date: string;
  weekday: Weekday;
  weekdayLord: Planet;
  sunrise: Date;
  sunset: Date;
  todayNakshatra: Nakshatra;
  todayNakshatraLord: Planet;
  transitMoonSign: ZodiacSign;
  transitMoonSignLord: Planet;
}

export interface HoraWindow {
  start: string;
  end: string;
  planet: Planet;
}

export interface DailyPredictionResult {
  rulingPlanet: Planet;
  luckyNumber: number;
  luckyColor: { name: string; nameHi: string; hex: string };
  luckyDirection: string;
  luckyDirectionHi: string;
  luckyTimeWindows: HoraWindow[];
  mantra: { sanskrit: string; meaning: string };
  scores: Record<string, number>;
}

function getLahiriAyanamsa(date: Date): number {
  const j2000 = new Date(Date.UTC(2000, 0, 1, 12, 0, 0));
  const daysSinceJ2000 = (date.getTime() - j2000.getTime()) / (1000 * 60 * 60 * 24);
  const yearsSinceJ2000 = daysSinceJ2000 / 365.25;
  return LAHIRI_AYANAMSA_J2000 + (yearsSinceJ2000 * AYANAMSA_ANNUAL_PRECESSION);
}

function tropicalToSidereal(tropicalLongitude: number, ayanamsa: number): number {
  let sidereal = tropicalLongitude - ayanamsa;
  if (sidereal < 0) sidereal += 360;
  return sidereal;
}

function getZodiacSign(siderealLongitude: number): ZodiacSign {
  const signIndex = Math.floor(siderealLongitude / 30) % 12;
  return ZODIAC_SIGNS[signIndex];
}

function getNakshatra(siderealLongitude: number): Nakshatra {
  const nakshatraIndex = Math.floor(siderealLongitude / (360 / 27)) % 27;
  return NAKSHATRA_LIST[nakshatraIndex];
}

function approximateMoonLongitude(date: Date): number {
  const j2000 = new Date(Date.UTC(2000, 0, 1, 12, 0, 0));
  const daysSinceJ2000 = (date.getTime() - j2000.getTime()) / (1000 * 60 * 60 * 24);
  const moonMeanAnomaly = (134.963 + 13.064993 * daysSinceJ2000) % 360;
  const sunMeanAnomaly = (357.529 + 0.985600 * daysSinceJ2000) % 360;
  const moonMeanElongation = (297.850 + 12.190749 * daysSinceJ2000) % 360;
  let moonLongitude = (218.316 + 13.176396 * daysSinceJ2000) % 360;
  moonLongitude += 6.289 * Math.sin((moonMeanAnomaly * Math.PI) / 180);
  moonLongitude -= 1.274 * Math.sin(((2 * moonMeanElongation - moonMeanAnomaly) * Math.PI) / 180);
  moonLongitude += 0.658 * Math.sin((2 * moonMeanElongation * Math.PI) / 180);
  moonLongitude -= 0.214 * Math.sin((2 * moonMeanAnomaly * Math.PI) / 180);
  moonLongitude -= 0.186 * Math.sin((sunMeanAnomaly * Math.PI) / 180);
  if (moonLongitude < 0) moonLongitude += 360;
  if (moonLongitude >= 360) moonLongitude -= 360;
  return moonLongitude;
}

function approximateSunLongitude(date: Date): number {
  const j2000 = new Date(Date.UTC(2000, 0, 1, 12, 0, 0));
  const daysSinceJ2000 = (date.getTime() - j2000.getTime()) / (1000 * 60 * 60 * 24);
  const meanLongitude = (280.460 + 0.9856474 * daysSinceJ2000) % 360;
  const meanAnomaly = (357.528 + 0.9856003 * daysSinceJ2000) % 360;
  const eclipticLongitude = meanLongitude + 
    1.915 * Math.sin((meanAnomaly * Math.PI) / 180) + 
    0.020 * Math.sin((2 * meanAnomaly * Math.PI) / 180);
  return eclipticLongitude >= 0 ? eclipticLongitude % 360 : (eclipticLongitude % 360) + 360;
}

function approximatePlanetLongitude(planet: Planet, date: Date): number {
  const j2000 = new Date(Date.UTC(2000, 0, 1, 12, 0, 0));
  const daysSinceJ2000 = (date.getTime() - j2000.getTime()) / (1000 * 60 * 60 * 24);
  const orbitalData: Record<string, { L0: number; dL: number }> = {
    'Mercury': { L0: 252.251, dL: 4.092317 },
    'Venus': { L0: 181.980, dL: 1.602136 },
    'Mars': { L0: 355.433, dL: 0.524039 },
    'Jupiter': { L0: 34.351, dL: 0.083056 },
    'Saturn': { L0: 50.077, dL: 0.033371 },
  };
  if (planet === 'Sun') return approximateSunLongitude(date);
  if (planet === 'Moon') return approximateMoonLongitude(date);
  if (planet === 'Rahu') {
    const rahuLongitude = (125.044 - 0.052954 * daysSinceJ2000) % 360;
    return rahuLongitude >= 0 ? rahuLongitude : rahuLongitude + 360;
  }
  if (planet === 'Ketu') {
    const rahuLongitude = (125.044 - 0.052954 * daysSinceJ2000) % 360;
    const ketuLongitude = (rahuLongitude + 180) % 360;
    return ketuLongitude >= 0 ? ketuLongitude : ketuLongitude + 360;
  }
  const data = orbitalData[planet];
  if (!data) return 0;
  let longitude = (data.L0 + data.dL * daysSinceJ2000) % 360;
  if (longitude < 0) longitude += 360;
  return longitude;
}

function approximateSunrise(date: Date, lat: number, lng: number): Date {
  const dayOfYear = Math.floor((date.getTime() - new Date(date.getFullYear(), 0, 0).getTime()) / (1000 * 60 * 60 * 24));
  const declination = 23.45 * Math.sin((360 / 365) * (dayOfYear - 81) * (Math.PI / 180));
  const latRad = lat * (Math.PI / 180);
  const decRad = declination * (Math.PI / 180);
  let hourAngle = Math.acos(-Math.tan(latRad) * Math.tan(decRad));
  hourAngle = hourAngle * (180 / Math.PI);
  const solarNoonOffset = lng / 15;
  const sunriseHour = 12 - (hourAngle / 15) - solarNoonOffset;
  const sunrise = new Date(date);
  sunrise.setHours(Math.floor(sunriseHour), Math.round((sunriseHour % 1) * 60), 0, 0);
  return sunrise;
}

function approximateSunset(date: Date, lat: number, lng: number): Date {
  const dayOfYear = Math.floor((date.getTime() - new Date(date.getFullYear(), 0, 0).getTime()) / (1000 * 60 * 60 * 24));
  const declination = 23.45 * Math.sin((360 / 365) * (dayOfYear - 81) * (Math.PI / 180));
  const latRad = lat * (Math.PI / 180);
  const decRad = declination * (Math.PI / 180);
  let hourAngle = Math.acos(-Math.tan(latRad) * Math.tan(decRad));
  hourAngle = hourAngle * (180 / Math.PI);
  const solarNoonOffset = lng / 15;
  const sunsetHour = 12 + (hourAngle / 15) - solarNoonOffset;
  const sunset = new Date(date);
  sunset.setHours(Math.floor(sunsetHour), Math.round((sunsetHour % 1) * 60), 0, 0);
  return sunset;
}

function getWeekday(date: Date): Weekday {
  const days: Weekday[] = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  return days[date.getDay()];
}

function getHouseNumber(planetSign: ZodiacSign, referenceSign: ZodiacSign): number {
  const planetIndex = ZODIAC_SIGNS.indexOf(planetSign);
  const refIndex = ZODIAC_SIGNS.indexOf(referenceSign);
  let house = planetIndex - refIndex + 1;
  if (house <= 0) house += 12;
  return house;
}

function getSignDignity(planet: Planet, sign: ZodiacSign): number {
  if (PLANET_EXALTATION[planet] === sign) return 10;
  if (PLANET_DEBILITATION[planet] === sign) return -10;
  if (PLANET_OWN_SIGNS[planet]?.includes(sign)) return 8;
  const signLord = SIGN_LORDS[sign];
  if (PLANET_FRIENDS[planet]?.includes(signLord)) return 4;
  if (PLANET_ENEMIES[planet]?.includes(signLord)) return -4;
  return 0;
}

function getHouseBonus(house: number): number {
  if ([1, 5, 9, 10, 11].includes(house)) return 3;
  if ([2, 3, 4, 7].includes(house)) return 1;
  if ([6, 8, 12].includes(house)) return -3;
  return 0;
}

function calculateNatalStrength(planet: Planet, planetSign: ZodiacSign, houseFromLagna: number): number {
  const dignity = getSignDignity(planet, planetSign);
  const houseBonus = getHouseBonus(houseFromLagna);
  return dignity + houseBonus;
}

export function computeNatalChart(
  birthDate: Date,
  birthTime: string,
  birthLat: number,
  birthLng: number
): NatalChart {
  const [hours, minutes] = birthTime.split(':').map(Number);
  const birthDateTime = new Date(birthDate);
  birthDateTime.setHours(hours, minutes, 0, 0);
  const ayanamsa = getLahiriAyanamsa(birthDateTime);
  const planets: Planet[] = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'];
  const planetSigns: Partial<Record<Planet, ZodiacSign>> = {};
  for (const planet of planets) {
    const tropicalLong = approximatePlanetLongitude(planet, birthDateTime);
    const siderealLong = tropicalToSidereal(tropicalLong, ayanamsa);
    planetSigns[planet] = getZodiacSign(siderealLong);
  }
  const moonTropical = approximateMoonLongitude(birthDateTime);
  const moonSidereal = tropicalToSidereal(moonTropical, ayanamsa);
  const moonSign = getZodiacSign(moonSidereal);
  const moonNakshatra = getNakshatra(moonSidereal);
  const moonNakshatraLord = NAKSHATRA_LORDS[moonNakshatra];
  const sunrise = approximateSunrise(birthDateTime, birthLat, birthLng);
  const hoursSinceSunrise = (birthDateTime.getTime() - sunrise.getTime()) / (1000 * 60 * 60);
  const lagnaOffset = (hoursSinceSunrise * 30) / 2;
  const sunTropical = approximateSunLongitude(birthDateTime);
  const sunSidereal = tropicalToSidereal(sunTropical, ayanamsa);
  let lagnaLongitude = sunSidereal + lagnaOffset;
  if (lagnaLongitude >= 360) lagnaLongitude -= 360;
  const lagnaSign = getZodiacSign(lagnaLongitude);
  const planetHouseFromLagna: Partial<Record<Planet, number>> = {};
  for (const planet of planets) {
    planetHouseFromLagna[planet] = getHouseNumber(planetSigns[planet]!, lagnaSign);
  }
  const natalStrength: Partial<Record<Planet, number>> = {};
  for (const planet of planets) {
    natalStrength[planet] = calculateNatalStrength(
      planet,
      planetSigns[planet]!,
      planetHouseFromLagna[planet]!
    );
  }
  return {
    lagnaSign,
    moonSign,
    moonNakshatra,
    moonNakshatraLord,
    sunSign: planetSigns['Sun']!,
    planetSigns: planetSigns as Record<Planet, ZodiacSign>,
    planetHouseFromLagna: planetHouseFromLagna as Record<Planet, number>,
    natalStrength: natalStrength as Record<Planet, number>,
  };
}

export function computeDailyPanchang(
  date: Date,
  lat: number,
  lng: number
): DailyPanchang {
  const sunrise = approximateSunrise(date, lat, lng);
  const sunset = approximateSunset(date, lat, lng);
  const weekday = getWeekday(date);
  const weekdayLord = WEEKDAY_LORDS[weekday];
  const ayanamsa = getLahiriAyanamsa(sunrise);
  const moonTropical = approximateMoonLongitude(sunrise);
  const moonSidereal = tropicalToSidereal(moonTropical, ayanamsa);
  const todayNakshatra = getNakshatra(moonSidereal);
  const todayNakshatraLord = NAKSHATRA_LORDS[todayNakshatra];
  const transitMoonSign = getZodiacSign(moonSidereal);
  const transitMoonSignLord = SIGN_LORDS[transitMoonSign];
  return {
    date: date.toISOString().split('T')[0],
    weekday,
    weekdayLord,
    sunrise,
    sunset,
    todayNakshatra,
    todayNakshatraLord,
    transitMoonSign,
    transitMoonSignLord,
  };
}

function getTransitModifier(planet: Planet, natalMoonSign: ZodiacSign, panchang: DailyPanchang): number {
  const ayanamsa = getLahiriAyanamsa(panchang.sunrise);
  const planetTropical = approximatePlanetLongitude(planet, panchang.sunrise);
  const planetSidereal = tropicalToSidereal(planetTropical, ayanamsa);
  const transitSign = getZodiacSign(planetSidereal);
  const houseFromMoon = getHouseNumber(transitSign, natalMoonSign);
  if ([1, 3, 6, 10, 11].includes(houseFromMoon)) return 3;
  if ([8, 12].includes(houseFromMoon)) return -3;
  return 0;
}

export function computeRulingPlanet(
  natalChart: NatalChart,
  panchang: DailyPanchang,
  yesterdayRPD?: Planet
): { rulingPlanet: Planet; scores: Record<string, number> } {
  const candidates = new Set<Planet>([
    panchang.weekdayLord,
    panchang.todayNakshatraLord,
    natalChart.moonNakshatraLord,
    panchang.transitMoonSignLord,
  ]);
  const baseWeights: Record<string, number> = {
    weekdayLord: 30,
    todayNakshatraLord: 25,
    natalMoonNakshatraLord: 20,
    transitMoonSignLord: 15,
  };
  const scores: Record<string, number> = {};
  for (const planet of candidates) {
    let score = 0;
    if (planet === panchang.weekdayLord) score += baseWeights.weekdayLord;
    if (planet === panchang.todayNakshatraLord) score += baseWeights.todayNakshatraLord;
    if (planet === natalChart.moonNakshatraLord) score += baseWeights.natalMoonNakshatraLord;
    if (planet === panchang.transitMoonSignLord) score += baseWeights.transitMoonSignLord;
    score += natalChart.natalStrength[planet] || 0;
    score += getTransitModifier(planet, natalChart.moonSign, panchang);
    scores[planet] = score;
  }
  const sortedPlanets = Array.from(candidates).sort((a, b) => {
    const scoreDiff = (scores[b] || 0) - (scores[a] || 0);
    if (scoreDiff !== 0) return scoreDiff;
    const priorityOrder: Planet[] = [
      panchang.weekdayLord,
      panchang.todayNakshatraLord,
      natalChart.moonNakshatraLord,
      panchang.transitMoonSignLord,
    ];
    return priorityOrder.indexOf(a) - priorityOrder.indexOf(b);
  });
  let topPlanet = sortedPlanets[0];
  if (yesterdayRPD && candidates.has(yesterdayRPD)) {
    const topScore = scores[topPlanet] || 0;
    const yesterdayScore = scores[yesterdayRPD] || 0;
    if (topPlanet !== yesterdayRPD && (topScore - yesterdayScore) < 12) {
      topPlanet = yesterdayRPD;
    }
  }
  return { rulingPlanet: topPlanet, scores };
}

export function computeHoraWindows(
  rulingPlanet: Planet,
  sunrise: Date,
  sunset: Date
): HoraWindow[] {
  const dayLength = sunset.getTime() - sunrise.getTime();
  const horaLengthDay = dayLength / 12;
  const nextSunrise = new Date(sunrise);
  nextSunrise.setDate(nextSunrise.getDate() + 1);
  const nightLength = nextSunrise.getTime() - sunset.getTime();
  const horaLengthNight = nightLength / 12;
  const weekday = getWeekday(sunrise);
  const firstHoraLord = WEEKDAY_LORDS[weekday];
  const chaldeanIndex = CHALDEAN_ORDER.indexOf(firstHoraLord);
  const allHoras: { start: Date; end: Date; planet: Planet }[] = [];
  for (let i = 0; i < 12; i++) {
    const planetIndex = (chaldeanIndex + i) % 7;
    const planet = CHALDEAN_ORDER[planetIndex];
    const start = new Date(sunrise.getTime() + i * horaLengthDay);
    const end = new Date(sunrise.getTime() + (i + 1) * horaLengthDay);
    allHoras.push({ start, end, planet });
  }
  for (let i = 0; i < 12; i++) {
    const planetIndex = (chaldeanIndex + 12 + i) % 7;
    const planet = CHALDEAN_ORDER[planetIndex];
    const start = new Date(sunset.getTime() + i * horaLengthNight);
    const end = new Date(sunset.getTime() + (i + 1) * horaLengthNight);
    allHoras.push({ start, end, planet });
  }
  const matchingHoras = allHoras.filter((hora) => {
    if (hora.planet !== rulingPlanet) return false;
    const startHour = hora.start.getHours() + hora.start.getMinutes() / 60;
    const endHour = hora.end.getHours() + hora.end.getMinutes() / 60;
    if (startHour < 7) return false;
    if (endHour > 22.5) return false;
    return true;
  });
  const formatTime = (date: Date): string => {
    const hours = date.getHours();
    const minutes = date.getMinutes();
    const ampm = hours >= 12 ? 'PM' : 'AM';
    const hour12 = hours % 12 || 12;
    return `${hour12}:${minutes.toString().padStart(2, '0')} ${ampm}`;
  };
  const windows: HoraWindow[] = matchingHoras.slice(0, 2).map((hora) => ({
    start: formatTime(hora.start),
    end: formatTime(hora.end),
    planet: hora.planet,
  }));
  if (windows.length === 0) {
    windows.push({
      start: '10:00 AM',
      end: '11:00 AM',
      planet: rulingPlanet,
    });
  }
  return windows;
}

export function generateDailyPrediction(
  natalChart: NatalChart,
  panchang: DailyPanchang,
  yesterdayRPD?: Planet
): DailyPredictionResult {
  const { rulingPlanet, scores } = computeRulingPlanet(natalChart, panchang, yesterdayRPD);
  const luckyNumber = PLANET_LUCKY_NUMBER[rulingPlanet];
  const luckyColor = PLANET_COLOR[rulingPlanet];
  const direction = PLANET_DIRECTION[rulingPlanet];
  const directionHindi: Record<string, string> = {
    'East': 'पूर्व',
    'West': 'पश्चिम',
    'North': 'उत्तर',
    'South': 'दक्षिण',
    'North-East': 'ईशान',
    'North-West': 'वायव्य',
    'South-East': 'आग्नेय',
    'South-West': 'नैऋत्य',
  };
  const luckyTimeWindows = computeHoraWindows(rulingPlanet, panchang.sunrise, panchang.sunset);
  const mantra = PLANET_MANTRA[rulingPlanet];
  return {
    rulingPlanet,
    luckyNumber,
    luckyColor,
    luckyDirection: direction,
    luckyDirectionHi: directionHindi[direction] || direction,
    luckyTimeWindows,
    mantra,
    scores,
  };
}
