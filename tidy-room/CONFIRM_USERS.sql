-- Manually confirm ALL existing users so they can log in
UPDATE auth.users
SET email_confirmed_at = now()
WHERE email_confirmed_at IS NULL;
