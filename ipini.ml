open Lwt
module C = Irc_client_lwt.Client

let host = "irc.exzen.eu"
let port = 6667
let realname = "Harmless OCaml experiment"
let nick = "ipini"
let username = nick
let channel = "##whatevers"
let password = "foo"
let message = "Hello, world!  This is a test from ocaml-irc-client"

let string_opt_to_string = function
  | None -> "None"
  | Some s -> Printf.sprintf "Some %s" s

let string_list_to_string string_list =
  Printf.sprintf "[%s]" (String.concat "; " string_list)

let callback ~connection ~result =
  let open Irc_message in
  match result with
  | Message {prefix=prefix; command=command; params=params; trail=trail} ->
    Lwt_io.printf "Got message: prefix=%s; command=%s; params=%s; trail=%s\n"
      (string_opt_to_string prefix)
      command
      (string_list_to_string params)
      (string_opt_to_string trail)
  | Parse_error (raw, error) ->
    Lwt_io.printf "Failed to parse \"%s\" because: %s" raw error

let lwt_main =
  Lwt_unix.gethostbyname host
  >>= fun he -> C.connect ~addr:(he.Lwt_unix.h_addr_list.(0))
    ~port ~username ~mode:0 ~realname ~nick ()
  >>= fun connection -> Lwt_io.printl "Connected"
  >>= fun () -> C.send_join ~connection ~channel:(channel ^ " " ^ password)
  >>= fun () -> C.send_privmsg ~connection ~target:channel ~message
  >>= fun () -> C.listen ~connection ~callback
  >>= fun () -> C.send_quit ~connection

let _ = Lwt_main.run lwt_main
