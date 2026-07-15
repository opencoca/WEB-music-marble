# Marble

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Single file](https://img.shields.io/badge/app-single%20HTML%20file-blue.svg)](index.html)
[![No dependencies](https://img.shields.io/badge/dependencies-none-brightgreen.svg)](index.html)
[![Web Audio API](https://img.shields.io/badge/audio-Web%20Audio%20API-orange.svg)](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API)

Tilt your phone and a marble rolls across the screen. Each wall plays a wood block tone when the marble hits it: C5 on the left, D5 on the right, E5 on top, G5 on the bottom. All four notes are from the C major pentatonic scale, so whatever the marble does, it sounds good. Louder hits play louder tones. Touch the screen and the surface bends, pulling the marble into orbit. Let go and the surface snaps flat, popping it back out.

Arrow keys work on desktop. Mouse click for the gravity well.

**Play it at [marble.startr.cloud](https://marble.startr.cloud).**

## Install

Marble is a PWA — it installs to your home screen and works offline.

- **Android / desktop Chrome and Edge**: tap **Get the app** on the start screen (or **Install app** in the hamburger menu), then Install. The browser's own install icon in the address bar works too.
- **iOS Safari**: tap the Share button, then **Add to Home Screen**. The in-app install panel walks you through it.

## Releasing an update

The service worker (`sw.js`) precaches the app shell with a cache named after its `VERSION` constant. Any change to `index.html`, `samples/`, or the icons requires bumping `VERSION` (e.g. `v1` → `v2`) in `sw.js` — that invalidates the old cache. Users get the new version on their second load after the deploy.

Common tasks are automated in the [Makefile](Makefile) — run `make` to list targets (`make icons`, `make og`, `make serve`, `make verify-prod`, …). The full launch process is documented in [docs/LAUNCH-PLAYBOOK.md](docs/LAUNCH-PLAYBOOK.md).

## Why pentatonic?

People keep independently arriving at the pentatonic scale. Chinese classical music uses it. So do West African griot traditions, Celtic folk, Japanese min'yo, Hungarian village songs, Andean huayno, and Indonesian gamelan (the slendro tuning). Bobby McFerrin did [a bit at the 2009 World Science Festival](https://www.youtube.com/watch?v=ne6tB2KiZuk) where he got an audience to sing pentatonic intervals they had never been taught. He says it works with every audience he's tried it on, anywhere in the world.

The reason is structural: pentatonic scales skip the half-step intervals that create tension. You cannot play a wrong note. The marble doesn't know what note comes next and it doesn't matter, because physics picks the sequence and the scale makes sure it works.

The four walls are tuned to C5, D5, E5, and G5.

## Why wood block?

Wood-on-wood percussion is one of the oldest sounds humans have organized music around.

The Buddhist muyu (Chinese), mokugyo (Japanese), and moktak (Korean) are wooden fish carved from a single block, hollowed out and struck during sutra chanting to keep rhythm. The fish shape means wakefulness, since fish don't close their eyes. These have been in continuous use for over a thousand years.

The West African balafon is a wooden-key xylophone with gourd resonators underneath, ancestor of the modern marimba. Traditionally pentatonic. The Javanese gambang kayu fills a similar role in gamelan ensembles, tuned to slendro (five roughly equidistant notes).

Claves are just two pieces of hardwood hit together, but they're the rhythmic spine of Afro-Cuban son and rumba. Everything else in the ensemble locks to the clave pattern.

Slit drums, hollowed tree trunks with edges carved to different thicknesses for different pitches, may be the oldest pitched percussion instruments anywhere. They turn up across Africa, Asia, the Americas, and Oceania.

Our synthesized version uses a tuned sine wave with an inharmonic overtone at 2.7x the fundamental (that ratio gives it a woody, hollow character) plus a short bandpass-filtered noise burst for the initial click.

## Where this comes from

### Gestural electronic instruments

[Suzanne Ciani](https://www.youtube.com/watch?v=eDG1nAtJdrA) spent decades performing on Don Buchla's synthesizers, which deliberately had no piano keyboard. Buchla replaced keys with capacitive touch plates he called a "multi-dimensional kinesthetic input port," where one touch could transpose, trigger, stop, and modulate all at once. That idea, one gesture controlling many sonic parameters, is what happens when you tilt the phone. There is no key per note. You steer the whole system at once.

The Theremin (1920s) got there first in a simpler way: wave your hands near two antennae, one for pitch, one for volume, and never touch the instrument at all. A phone accelerometer reading your tilt angle is the same basic relationship between body movement and electronic sound.

### Rolling balls that make music

[George Rhoads](https://www.youtube.com/watch?v=ZvyI1AyVjaA) built audiokinetic sculptures starting in the late 1950s. Balls roll down tracks under gravity and strike bells, gongs, and xylophone bars along the way. His [*42nd Street Ballroom*](https://www.youtube.com/watch?v=Ccm1Tj21BS8) (1981) sat in the Port Authority bus terminal in NYC, where commuters watched marbles make music on their way to work. This project is basically a Rhoads sculpture in your pocket.

[Zimoun](https://www.youtube.com/watch?v=f307TEHiKGA), a Swiss artist, takes it further. His piece *294 prepared dc-motors, cork balls, cardboard boxes* (2012) has motors bouncing cork balls against cardboard. There is no score. He sets the system running and whatever sound comes out is the composition.

Martin Molin's [Wintergatan Marble Machine](https://www.youtube.com/watch?v=IvUU8joBb1Q) (2016) drops 2,000 steel marbles onto vibraphone bars, bass strings, and drums.

### Chance music

Iannis Xenakis composed *Pithoprakta* (1956) by modelling gas molecules bouncing in a container and turning their statistical behavior into an orchestral score. A marble bouncing inside a phone screen is a small-scale version of the same physics.

John Cage's *Music of Changes* (1951) used the I Ching to decide which notes came next. The composer steps aside and lets a system choose. Here, the system is Newtonian mechanics.

The rainstick (a dried cactus tube with internal pegs, filled with seeds, originally Mapuche) might be the oldest version of this idea. Tilt the tube and gravity pulls the seeds through obstacles, making sound through collision. That's exactly what happens here, minus the cactus.

### Balls and walls, historically

The Mesoamerican ball game ran for over 3,000 years across Maya, Aztec, and Olmec civilizations. A rubber ball bouncing off stone court walls had cosmological meaning: the ball was the sun, the court was the cosmos. The courts were acoustic spaces too, since parallel stone walls create specific resonances. People have been listening to balls hit walls for a long time.

## Running locally

iOS requires HTTPS for device orientation permissions, so you need a tunnel or a cert:

```bash
python3 -m http.server 8787 &
cloudflared tunnel --url http://localhost:8787
```

Open the tunnel URL on your phone, tap Start Simulation, and tilt.

## Controls

| Input | Effect |
|---|---|
| Device tilt | Gravity direction (mobile) |
| Arrow keys | Simulated tilt (desktop) |
| Touch / click-hold | Bend the surface (marble rolls in and orbits) |
| Move while holding | Drag the depression around |
| Release | Surface snaps flat and pops the marble out |
| Hamburger menu | Switch gravity mode, real vs synthesized sound, mute, debug |

The menu has two gravity modes. Surface bend (default) warps the plane like a rubber sheet, so force peaks in a ring around your finger and orbits feel natural. Point attractor is classic inverse-square pull. Sound can come from a synthesized wood block or a [real woodblock sample](https://freewavesamples.com/woodblock) pitch-shifted to each wall's note.

## How it sounds

The four walls make a pentatonic chord. Hit a corner and you get two notes in quick succession. Rest against a wall and it goes quiet, since sound only fires on initial contact. Hard hits are loud, gentle ones are soft. Send the marble ricocheting off all four walls and you get a little melody that can't sound bad.

## License

MIT
