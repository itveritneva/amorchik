-- Уведомление в Telegram (бот Аморчика) о каждой новой записи в waitlist.
-- Email в сообщение НЕ попадает: на лендинге обещано, что контакт не передаётся третьим лицам.
-- Токен бота хранится в Supabase Vault под именем 'amorchik_bot_token' (добавляется руками в дашборде).

create extension if not exists pg_net;

create or replace function public.notify_waitlist_signup()
returns trigger
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  bot_token text;
  total bigint;
  stage_ru text;
  msg text;
begin
  select decrypted_secret into bot_token
  from vault.decrypted_secrets where name = 'amorchik_bot_token' limit 1;
  if bot_token is null then
    return new;
  end if;

  select count(*) into total from public.amorchik_waitlist;

  stage_ru := case new.stage
    when 'trying' then 'пробуют сами'
    when 'tests' then 'обследования'
    when 'ivf' then 'ЭКО'
    when 'pregnant' then 'уже беременна'
    when 'partner' then 'партнёр'
    when 'other' then 'другое'
    else 'не указан'
  end;

  msg := 'Новая запись в waitlist Аморчика' || chr(10)
      || 'Всего: ' || total || chr(10)
      || 'Этап: ' || stage_ru || chr(10)
      || 'Откуда: ' || coalesce(new.source, 'прямой заход') || chr(10)
      || 'Email смотри в Supabase → Table Editor → amorchik_waitlist';

  perform net.http_post(
    url := 'https://api.telegram.org/bot' || bot_token || '/sendMessage',
    body := jsonb_build_object('chat_id', 1178733225, 'text', msg),
    headers := '{"Content-Type": "application/json"}'::jsonb
  );
  return new;
end;
$$;

revoke all on function public.notify_waitlist_signup() from public, anon, authenticated;

drop trigger if exists waitlist_notify on public.amorchik_waitlist;
create trigger waitlist_notify
  after insert on public.amorchik_waitlist
  for each row execute function public.notify_waitlist_signup();
