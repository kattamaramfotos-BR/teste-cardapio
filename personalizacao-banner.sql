-- PERSONALIZAÇÃO DA CAPA DO CARDÁPIO
-- Execute uma única vez no Supabase SQL Editor.
-- Não apaga nem altera produtos, categorias, usuários ou imagens existentes.

alter table public.boats
  add column if not exists cover_height integer not null default 480,
  add column if not exists cover_width integer not null default 100,
  add column if not exists cover_zoom integer not null default 100,
  add column if not exists cover_x integer not null default 50,
  add column if not exists cover_y integer not null default 50,
  add column if not exists cover_overlay integer not null default 45;

-- Garante valores padrão para registros antigos, caso existam valores nulos.
update public.boats
set cover_height = coalesce(cover_height, 480),
    cover_width = coalesce(cover_width, 100),
    cover_zoom = coalesce(cover_zoom, 100),
    cover_x = coalesce(cover_x, 50),
    cover_y = coalesce(cover_y, 50),
    cover_overlay = coalesce(cover_overlay, 45)
where cover_height is null
   or cover_width is null
   or cover_zoom is null
   or cover_x is null
   or cover_y is null
   or cover_overlay is null;
