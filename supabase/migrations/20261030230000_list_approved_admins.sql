-- Menampilkan akun yang sudah disetujui di List Admin meskipun belum punya baris profiles.
-- Jalankan file ini sekali melalui Supabase Dashboard > SQL Editor.
create or replace function public.list_jastip_profiles() returns json
language sql stable security definer set search_path = public as $$
  select case
    when public.is_developer() then
      coalesce(
        (
          select json_agg(
            json_build_object(
              'id', u.id,
              'email', u.email,
              'nama', coalesce(
                nullif(p.nama, ''),
                nullif(r.nama, ''),
                nullif(u.raw_user_meta_data->>'nama', ''),
                split_part(u.email, '@', 1)
              ),
              'cojastip', coalesce(p.cojastip, false),
              'online', coalesce(p.online, false)
            )
            order by coalesce(
              nullif(p.nama, ''),
              nullif(r.nama, ''),
              nullif(u.raw_user_meta_data->>'nama', ''),
              split_part(u.email, '@', 1)
            )
          )
          from auth.users u
          left join public.profiles p on p.id = u.id
          left join public.permintaan_jastip r on r.user_id = u.id
          where p.id is not null or r.status = 'disetujui'
        ),
        '[]'::json
      )
    else '[]'::json
  end
$$;

grant execute on function public.list_jastip_profiles() to authenticated;
