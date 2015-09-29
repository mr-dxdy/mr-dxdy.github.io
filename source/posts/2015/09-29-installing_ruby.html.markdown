---
title: Installing Ruby
date: 2015-09-29 09:15 MSK
tags:
- Новости
- Ruby
---

## Patch 41808

При установке ruby-1.9.3 возникает ошибка:

```
ec_group_new_curve_gf2m' undeclared (first use in this function)
```

Проблема решается с помощью установки патча:

```
curl -fsSL https://gist.githubusercontent.com/petems/8420477/raw/4b23330b5c3cb5616eb90908c98421e4873e6ca6/41808.diff | rbenv install --patch 1.9.3-p194
```
READMORE
Source code of patch #41808:

``` cpp
Index: ext/openssl/ossl_pkey_ec.c
===================================================================
--- ext/openssl/ossl_pkey_ec.c  (revision 41807)
+++ ext/openssl/ossl_pkey_ec.c  (revision 41808)
@@ -757,8 +757,10 @@
                 method = EC_GFp_mont_method();
             } else if (id == s_GFp_nist) {
                 method = EC_GFp_nist_method();
+#if !defined(OPENSSL_NO_EC2M)
             } else if (id == s_GF2m_simple) {
                 method = EC_GF2m_simple_method();
+#endif
             }

             if (method) {
@@ -811,8 +811,10 @@

             if (id == s_GFp) {
                 new_curve = EC_GROUP_new_curve_GFp;
+#if !defined(OPENSSL_NO_EC2M)
             } else if (id == s_GF2m) {
                 new_curve = EC_GROUP_new_curve_GF2m;
+#endif
             } else {
                 rb_raise(rb_eArgError, "unknown symbol, must be :GFp or :GF2m");
             }
```

Аналогичная ситуация возникает при установке ruby-1.8.7-p375:

``` bash
curl -fsSL https://gist.github.com/thescouser89/8102408/raw/417cba9fee6ba1945b967b5ef236f676bd5005e0/1.8.7-rbenv.patch | rbenv install --patch 1.8.7-p375

```

``` cpp
--- ext/openssl/ossl_pkey_ec.c
+++ ext/openssl/ossl_pkey_ec.c
@@ -757,8 +757,10 @@ static VALUE ossl_ec_group_initialize(int argc, VALUE *argv, VALUE self)
                 method = EC_GFp_mont_method();
             } else if (id == s_GFp_nist) {
                 method = EC_GFp_nist_method();
+#if !defined(OPENSSl_NO_EC2M)
             } else if (id == s_GF2m_simple) {
                 method = EC_GF2m_simple_method();
+#endif
             }

             if (method) {
@@ -811,8 +813,10 @@ static VALUE ossl_ec_group_initialize(int argc, VALUE *argv, VALUE self)

             if (id == s_GFp) {
                 new_curve = EC_GROUP_new_curve_GFp;
+#if !defined(OPENSSL_NO_EC2M)
             } else if (id == s_GF2m) {
                 new_curve = EC_GROUP_new_curve_GF2m;
+#endif
             } else {
                 rb_raise(rb_eArgError, "unknown symbol, must be :GFp or :GF2m");
             }
```

### Источник
[Ruby-build WIKI](https://github.com/sstephenson/ruby-build/wiki#make-error-for-200-p247-and-lower-on-fedorared-hat)


## Readline (LoadError)

I was greeted with the following message:

``` bash
require: cannot load such file -- readline (LoadError)
```

The solutions:

``` bash
# zypper install libreadline5
curl -fsSL https://gist.github.com/LeonB/10503374/raw | rbenv install --patch 2.0.0-p451
```

Source code of patch:

``` cpp
diff --git ext/readline/extconf.rb ext/readline/extconf.rb
index 4920137..8e81253 100644
--- ext/readline/extconf.rb
+++ ext/readline/extconf.rb
@@ -19,6 +19,10 @@ def readline.have_func(func)
   return super(func, headers)
 end

+def readline.have_type(type)
+  return super(type, headers)
+end
+
 dir_config('curses')
 dir_config('ncurses')
 dir_config('termcap')
@@ -93,4 +97,9 @@ readline.have_func("remove_history")
 readline.have_func("clear_history")
 readline.have_func("rl_redisplay")
 readline.have_func("rl_insert_text")
+
+unless readline.have_type("rl_hook_func_t")
+  $defs << "-Drl_hook_func_t=Function"
+end
+
 create_makefile("readline")
diff --git ext/readline/readline.c ext/readline/readline.c
index 3e7feea..482bf80 100644
--- ext/readline/readline.c
+++ ext/readline/readline.c
@@ -1883,7 +1883,7 @@ Init_readline()

     rl_attempted_completion_function = readline_attempted_completion_function;
 #if defined(HAVE_RL_PRE_INPUT_HOOK)
-    rl_pre_input_hook = (Function *)readline_pre_input_hook;
+    rl_pre_input_hook = (rl_hook_func_t *)readline_pre_input_hook;
 #endif
 #ifdef HAVE_RL_CATCH_SIGNALS
     rl_catch_signals = 0;
```

Source:

[Readline error when building ruby](http://www.markholmberg.com/articles/readline-error-when-building-ruby)


## Compiling readline.c

Ошибка при установке ruby 2.0.0:

``` cpp
compiling readline.c
readline.c: In function ‘Init_readline’:
readline.c:1886:26: error: ‘Function’ undeclared (first use in this function)
rl_pre_input_hook = (Function *)readline_pre_input_hook;
^
readline.c:1886:26: note: each undeclared identifier is reported only once for each function it appears in
readline.c:1886:36: error: expected expression before ‘)’ token
rl_pre_input_hook = (Function *)readline_pre_input_hook;
^
readline.c: At top level:
readline.c:530:1: warning: ‘readline_pre_input_hook’ defined but not used [-Wunused-function]
readline_pre_input_hook(void)
^
make[2]: *** [readline.o] Ошибка 1
```

## Решение

``` bash
curl -fsSL https://gist.github.com/LeonB/10503374/raw | rbenv install --patch 2.0.0-p451
```
