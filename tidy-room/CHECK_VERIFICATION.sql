-- CHECK IF USERS ARE VERIFIED
SELECT 
    email, 
    created_at, 
    email_confirmed_at, 
    last_sign_in_at 
FROM auth.users 
ORDER BY created_at DESC 
LIMIT 5;
