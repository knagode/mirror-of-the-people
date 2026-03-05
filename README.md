# ZrcaloLjudi

Povej kaj si želiš od države, umetna inteligenca ti pove katere stranke so ti najbližje.

**Demo:** [policymirror.herokuapp.com](https://policymirror-52b9ce0d1595.herokuapp.com)

## Kako deluje?

1. Uporabnik napiše svojo željo (npr. "Želim si nižje davke in boljše javno zdravstvo")
2. Claude AI primerja željo s programi 14 slovenskih političnih strank
3. Prikaže rezultate z % ujemanja in obrazložitvijo za vsako stranko
4. Uporabnik si sčasoma zgradi profil - več želj kot poda, natančnejši je profil

## Funkcionalnosti

- **AI analiza** - Claude AI primerja želje s strankarskimi programi
- **Profil** - trajni URL za ohranitev želj med sejami in napravami
- **Glasovanje** - upvote/downvote želj drugih uporabnikov
- **Statistika** - agregirani rezultati vseh uporabnikov (uteženi z glasovi)
- **Turbo** - asinhrono nalaganje rezultatov brez čakanja

## Stranke v bazi

GS, SDS, NSi, SD, Levica, Vesna, SNS, SLS, DeSUS, SAB, Piratska stranka, Resni.ca, Naši, Dobra država

## Tehnologije

- Ruby on Rails 8
- PostgreSQL
- [Claude API](https://docs.anthropic.com/) (Anthropic)
- Hotwire (Turbo Frames)

## Lokalni razvoj

```bash
git clone https://github.com/knagode/policy-mirror.git
cd policy-mirror
bundle install
```

Ustvari `.env.development`:

```
ANTHROPIC_API_KEY=tvoj_kljuc
```

Nastavi bazo in zaženi:

```bash
bin/rails db:create db:migrate db:seed
bin/rails server
```

Odpri http://localhost:3000

## Deployment (Heroku)

```bash
heroku config:set ANTHROPIC_API_KEY=tvoj_kljuc -a policymirror
git push heroku main
heroku run rails db:seed -a policymirror
```

Migracije se avtomatsko poženejo ob deployu (Procfile release phase).

## Prispevki

Projekt je odprtokoden. Pull requesti so dobrodošli!

## Licenca

MIT
