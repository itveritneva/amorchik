# Аморчик — лендинг и waitlist

Статическая страница (GitHub Pages) с формой раннего доступа.

- Форма пишет в Supabase, проект `amorchik` (Frankfurt), таблица `amorchik_waitlist`. Схема в `supabase/waitlist.sql`.
- Публичный ключ (`sb_publishable_…`) может только добавлять строки. Читать список можно только из дашборда Supabase: Table Editor → amorchik_waitlist.
- `?src=reels` в ссылке записывается в колонку `source`.
- `.github/workflows/keepalive.yml` пингует базу каждые 3 дня, чтобы бесплатный проект не засыпал.
