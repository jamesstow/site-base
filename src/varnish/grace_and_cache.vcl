vcl 4.0;
import std;

sub vcl_init {
  return (ok);
}

sub vcl_fini {
  return (ok);
}

sub vcl_recv {
  if(req.method == "PURGE") {
    if(std.ip(regsub(req.http.X-Forwarded-For, "[, ].*$", ""), client.ip) !~ purge) {
      return (synth(405, "Method not allowed"));
    }

    return (hash);
  }

  set req.backend_hint = web;  

  if(req.method != "GET" &&
    req.method != "HEAD" &&
    req.method != "PUT" &&
    req.method != "POST" &&
    req.method != "TRACE" &&
    req.method != "OPTIONS" &&
    req.method != "DELETE") {
    /* Non-RFC2616 or CONNECT which is weird. */
    return (synth(405, "Method not allowed"));
    //return (pipe);
  }

  if(req.method != "GET" && req.method != "HEAD" || req.url ~ "wp-(login|admin)" || req.url ~ "preview=true" || req.url ~ "xmlrpc.php") {
    /* We only deal with GET and HEAD by default */
    return (pass);
  }

  if(req.http.Cookie) {
    unset req.http.Cookie;
  }

  return (hash);
}

sub vcl_pipe {
  # Note that only the first request to the backend will have
  # X-Forwarded-For set.  If you use X-Forwarded-For and want to
  # have it set for all requests, make sure to have:
  # set bereq.http.connection = "close";
  # here.  It is not set by default as it might break some broken web
  # applications, like IIS with NTLM authentication.

  return (pipe);
}

sub vcl_pass {
  return (fetch);
}

sub vcl_hash {
  hash_data(req.url);
  if(req.http.host) {
    hash_data(req.http.host);
  } else {
    hash_data(server.ip);
  }

  hash_data(req.http.X-Forwarded-Proto);

  return (lookup);
}

sub vcl_hit {
   if (obj.ttl >= 0s) {
       // A pure unadultered hit, deliver it
       return (deliver);
   }
   if (obj.ttl + obj.grace > 0s) {
       // Object is in grace, deliver it
       // Automatically triggers a background fetch
       return (deliver);
   }
   // fetch & deliver once we get the result
   return (fetch);
}

sub vcl_miss {
  return (fetch);
}

sub vcl_backend_response {
  set beresp.grace = 48h;
  set beresp.ttl = 10s;

  return (deliver);
}

sub vcl_deliver {
  if ((req.http.X-UA-Device) && (resp.http.Vary)) {
    set resp.http.Vary = regsub(resp.http.Vary, "X-UA-Device", "User-Agent");
  }

  if(req.http.X-purger) {
    set resp.http.X-purger = req.http.X-purger;
  }

  if(resp.http.X-Varnish){
    unset resp.http.X-Varnish;
  }

  /*
  if(resp.http.Age){
    unset resp.http.Age;
  }  
  */

  if(resp.http.X-Varnish){
    unset resp.http.X-Varnish;
  } 

  if(resp.http.Via){
    unset resp.http.Via;
  } 

  if(resp.http.X-Powered-By){
    unset resp.http.X-Powered-By;
  }

  if(resp.http.Server){
    unset resp.http.Server;
  }

  return (deliver);
}

sub vcl_synth {
  
}

