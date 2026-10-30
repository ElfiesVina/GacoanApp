
-- Daftar sesi yang masih dibuka (untuk "Sesi terbaru" di halaman Jastiper, semua perangkat).
create or replace function list_sesi_aktif() returns json
language sql security definer set search_path = public as $$
  select coalesce(json_agg(json_build_object('kode', t.kode, 'judul', t.judul, 'nama', t.nama)
    order by t.created_at desc), '[]'::json)
  from (
    select s.kode, s.judul, s.created_at, p.nama
    from sesi s left join profiles p on p.id = s.owner
    where s.status = 'open'
    order by s.created_at desc
    limit 10
  ) t
$$;
grant execute on function list_sesi_aktif() to anon, authenticated;