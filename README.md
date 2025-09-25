# Project: SQL Injections and Web Attacks

This assignment will explore three different web-based attacks: SQL Injection,
Cross-Site Scripting (XSS), and Cross-Site Request Forgery (CSRF).

# Getting up and running: QEMU and Docker
Install QEMU
This can most easily be done by using brew: 

```bash
brew install qemu
```
This will install multiple different tools to let you emulate different architectures on your Mac; the one we will be using is qemu-system-x86_64
# Download the QEMU VM
in the file

## New options to the QEMU command

The web servers will run in a Docker container (more on that below). It is possible
that, if you are using an x86 machine, you *might* not need to run the Docker
containers within the VM we provided; please feel free to try it out and share
your successes on Piazza.

But if you are unable to run the Docker containers outside the VM, then you
will be using the same QEMU VM that you used for project 1, but this time we
will need to set up a bit more port forwarding, so the command has changed
somewhat to the following:

   ```
   qemu-system-x86_64 -accel tcg -m 4G -drive if=virtio,format=qcow2,file=cmsc414.qcow2 -nic user,model=virtio,hostfwd=tcp:127.0.0.1:41422-:22,hostfwd=tcp:127.0.0.1:41481-:41481,hostfwd=tcp:127.0.0.1:41482-:41482,hostfwd=tcp:127.0.0.1:41483-:41483
   ```

The difference is that we added more `hostfwd=...` (port forwarding) options at
the end. This will help make it much easier to work outside of your VM.

Remember to safely `shutdown -h now` your VM before restarting it with the above
command to start the VM.
## Logging into the VM
The pre-established user credentials for this VM are:

```bash
Username: cmsc414
Password: cmsc414
```
From your terminal (in macOS), you can ssh into the VM with the following command:

```bash
ssh -p 41422 cmsc414@localhost
```

This says to log into the VM (running on your local machine on port 41422) as the user cmsc414. This will prompt you for the password; enter cmsc414 (unless you update the password). (You might also want to set up SSH keys to avoid having to enter in passwords.)

If successful, you will see a command prompt starting with cmsc414@cmsc414:~$

## Docker

The tasks will all use docker images that have fully-configured servers that
are vulnerable to the various attacks.  While this might sound somewhat
complicated (docker inside of a VM), when it's all set up right, you'll be able
to do the project through your normal browser, outside the VM altogether!

First, make sure there is no service on your machine listening on ports 41481,
41482, or 41483. (It is unlikely that there is.) 

We will step you through the key commands to get docker running, but for more
information, please see [Mike Marsh's Docker
tutorial](https://gitlab.cs.umd.edu/mmarsh/docker-tutorial).

### Getting and loading docker images

All docker images are available on ELMS in the form of tar files; there's one
for each of the three attacks (sqli.tar, xss.tar, and csrf.tar).

Download these to your computer and then copy them into your QEMU VM. Assuming
the VM is running, then from your host OS (outside the VM), you can simply run
the following (this example shows it for the SQL injection docker image; it's
similar for the other ones):

   ```
   scp -P41422 sqli.tar cmsc414@localhost:
   ```

Then ssh into the QEMU VM and load each docker image individually with the
`docker image load` command, which can sometimes time a couple minutes in the
VM. For instance, to load the SQL injection docker image, run the following
from within the QEMU VM:

   ```
   docker image load sqli.tar
   ```

Many students have reported that running shell commands from within VS Code
can be extremely slow. We *highly* recommend you run these commands outside
of VS Code, from just a normal terminal.

**Please note that we will have no access to the server containers that you are
running locally, so you will need to include *everything* necessary to
demonstrate your attacks in the files you submit.**

## Testing from outside the VM

Once you have your Docker container running, you will not have to do (most of)
your testing from within the VM! Rather, you can simply open up your own host OS's
browser and connect to the webpages running in the Docker container (which is
running in the VM, unless you found a way to run the Docker container outside
the VM).

However, you will benefit from looking at some of the files stored within the
Docker container; please pay close attention to the spec to make sure you catch
all of the specific files referenced.

## More project compatibility notes

For the Java code you will be writing, please ensure that it is compliant with
**Java 1.8**.

For the task .txt files you submit, make sure that your editor does not insert
"smart" quotes; our auto-grader will be using good old fashioned single quotes
(ASCII character 0x27) and double quotes (ASCII character 0x22).

For all tasks, pay close attention to the formatting specified. There's a
difference between single and double quotes, and the automated grading will be
very unhappy if you use single quotes where you should have used double quotes.
Not following the formatting properly is *the major reason* for people not
getting points on task 2. In particular, the initial lines for the first 2
tasks represent the fields the auto-grader will enter into the relevant HTML
forms, so please include **all** of the needed fields **exactly** as you would
*enter* them manually. For tasks 3 and 5, the files you provide will be used
verbatim and in their entirety, so please do not include additional
information. For task 5, you may include HTML comments, but for task 3, if you
feel the need to include additional information, please place it in a separate
file.

Use the check scripts to verify your files' formatting, but bear in mind that
that is **all** the checker scripts are testing.

# SQL Injection Attacks (45 points)

Your goal in these tasks is to find ways to exploit the SQL-Injection
vulnerabilities and demonstrate the damage that can be achieved by the attacks.

Steps for running docker image:

1. Start the server by running the following command from within your QEMU VM:

   ```
   docker run -d -p 41481:80 --name sql_server sqli
   ```

2. To test that the web server is running inside the VM, you can run `curl
   localhost:41481`; if the web server is running, you will see HTML printed to
   stdout.

3. You can access the server in your own browser -- outside the VM altogether! -- at

    http://localhost:41481/

You will not have to modify any of the files inside of the docker container or
QEMU VM; all of your work for this task will be taking place strictly by
interacting with the vulnerable webpage through your browser.  However, it will
be very helpful for you to examine some of the files in the docker image.

If you want to examine files in the docker container, you have several options,
all of which you have to run from within your QEMU VM:

 1. `docker exec -ti sql_server bash`
 2. `docker exec sql_server cat <filename>`
 3. `docker cp sql_server:<filename> <local filename>`

The first option gives you a shell on the running container; the commands
available to you are somewhat limited, but enough to navigate the file system
and look at the contents of files. The second will simply dump the contents of
the file (replace `<filename>` with the full path to the file) to STDOUT. The
third will copy the file to a local name, and behaves very similarly to the
normal `cp` command.

For these tasks, the server you are attacking is called Collabtive, which is a
web-based project management system. It has several user accounts configured.
To see all the users' account information, first log in as the admin using the
following password; other users' account information can be obtained from the
post on the front page ("Users' Account Information"; then click on the
"Description" drop-down toggle near the top of the page).

   ```
   username: admin 
   password: admin
   ```

## Task 1: SQL Injection Attack on SELECT Statements (15 points)

In this task, you need to manage to log into Collabtive without providing a
password. You can achieve this using SQL injections on the login page.

Normally, before users start using Collabtive, they need to login using their
user names and passwords. Collabtive displays a login window to users and ask
them to input their username and password. The authentication is implemented by
`include/class.user.php` in the Collabtive root directory (`/var/www/html/`).
It uses the user-provided data to find out whether they match with the username
and user password fields of any record in the database. If there is a match, it
means the user has provided a correct user name and password combination, and
should be allowed to login. Like most web applications, PHP programs interact
with their back-end databases using the SQL language, in our case MySQL's
dialect.

In Collabtive, the following SQL query is constructed in class.user.php to
authenticate users:

    $sel1 = mysql_query ("SELECT ID, name, locale, lastlogin, gender, 
                          FROM user 
                          WHERE ((name = '$user') OR (email = '$user')) AND (pass = '$pass')");
    
    $chk = mysql_fetch_array($sel1);
    
    if (found one record) 
        then {allow the user to login}

In the above SQL statement, `user` is the name of the table containing information
about registered users.  The variable `$user` holds the string typed in the
Username textbox, and `$pass` holds the string typed in the Password textbox.
User's inputs in these two textboxs are placed directly in the SQL query
string.


### Submission

Your task is to login as bob without using his password. Please
submit a file called `task1.txt`. The first two lines should be the values you
entered in the login and password fields surrounded by double quotes. The two
lines should look exactly as follows, with your inputs in place of the `-`

    login="-" 
    password="-" 

Be sure to use the checker script to ensure that your file is formatted
properly.

### SQL comments

We want you to use the form of comments we described in class (with the double
dashes `--`). Some versions of SQL permit other forms of comments (like `#`); 
using this will result in a deduction of points.

### Points distribution
- 15 points for a successful log-in
- -5 points for using `#` as a SQL comment
- Additional points off for badly formatted files (see checker script)

## Task 2: SQL Injection on UPDATE Statements (30 points)

In this task, you need to make an unauthorized modification to the database.
Your goal is to modify another user's profile using SQL injections. In
Collabtive, if users want to update their profiles, they can go to "My
account", click the "Edit" link, and then fill out a form to update the profile
information. After the user sends the update request to the server, an `UPDATE`
statement will be constructed in `include/class.user.php`. (There are several
`UPDATE` statements in this file; inspect the file to determine which one is
used when editing a user's profile.)

The objective of this statement is to modify the current user's profile
information in the users table. There is a SQL injection vulnerability in this
SQL statement. Please find the vulnerability, and then use it to change another
user's profile without knowing their password. For example, if you are logged
in as Alice, your goal is to use the vulnerability to modify Bob's profile
information, including Bob's password. After the attack, you should be able to
log into Bob's account with this new password.

Note that passwords are not stored in their raw form in the database. If you
examine the `include/class.user.php` file, you will see how they store and
check passwords.

### Submission

Your task is to change Bob's password by modifying a different
users profile. Please submit a file called `task2.txt` with the following
format:

 * line 1: Bob's new password after your injection, wrapped in double quotes.

 * line 2: User whose profile you are modifying (*not* Bob or Admin), without
           quotes.

 * lines 3-n:
     One line for each profile parameter you changed, like so:

     ```
     "param"="new value"
     ```

     Please note that both the parameter name and new value should be
     wrapped in double quotes, so that we can clearly see any spaces
     you might have added. Also, the parameter name should be exactly
     as it appears in the HTML source code, *not* what you see on the
     webpage. You will have to examine the HTML or network traffic for
     these. (Hint: If your parameters begin with capital letters or
     dollar signs, you have the wrong parameter names.) The new value
     should be *exactly* what you type into the corresponding field of
     the form, including the injection.  If you don't do this, the
     automated grading will mark this task as failing. *All*
     parameters that you need to set must be included here for the
     automated grading to succeed.

 * line n+1: A blank line 

 * lines n+2 to end: The remaining lines should contain a short write
     up explaining the steps you used to create a working SQL
     injection attack that updates Bob's password to a new value.
     This is especially important if you mis-format the parameter
     lines, since it's the most likely way we'll be able to figure out
     what you actually should have entered during manual regrading, if
     needed.

For example (indentation not required):

    "newpasswd"
    alice
    "foo"="bar"
    "baz"="blah"

    Other explanatory stuff.

Be sure to use the checker script to ensure `task2.txt` is formatted properly.

### SQL comments

We want you to use the form of comments we described in class (with the double
dashes `--`). Some versions of SQL permit other forms of comments (like `#`); 
using this will result in a deduction of points.

### Points distribution
- 30 points: Successfully logging in as Bob
- -10 points for using `#` as a SQL comment

# XSS Attack (35 points)

Your goal in these tasks is to find ways to exploit the Cross-Site Scripting
vulnerabilities and demonstrate the damage that can be achieved by the attacks.

Steps for running docker image:

1. Start the server by running

   ```
   docker run -d -p 41482:80 --name xss_server xss
   ```
   
2. You can access the server in your browser at

    http://localhost:41482/

For these tasks, the server you are attacking is called Elgg, which is a social
networking application. 

## User login info

Elgg has several user accounts configured, with the following credentials:

    USER     USERNAME  PASSWORD
    =======  ========  ===========
    Admin    admin     seedelgg
    Alice    alice     seedalice
    Boby     boby      seedboby
    Charlie  charlie   seedcharlie
    Samy     samy      seedsamy

## Warmup - No submission Necessary 

The objective of this task is to embed a JavaScript program in your
Elgg profile, such that when another user views your profile, the
JavaScript program will be executed and an alert window will be
displayed. The following JavaScript program will display an alert
window:
 	
      <script>alert('XSS')</script> 

If you embed the above JavaScript code in your profile (e.g. in the
brief description field), then any user who views your profile will
see the alert window.
  
Our next objective is to embed a JavaScript program in your Elgg
profile, such that when another user views your profile, the user's
cookies will be displayed in the alert window. This can be done by
adding some additional code to the JavaScript program in the previous
example:
  
      <script>alert(document.cookie);</script> 

## Task 3: Stealing Cookies from the Victim's machine  (10 points)

In the previous task, the malicious JavaScript code written by the attacker can
print out the user's cookies, but only the user can see the cookies, not the
attacker. In this task, the attacker wants the JavaScript code to send the
cookies to themselves. To achieve this, the malicious JavaScript code needs to
send an HTTP request to the attacker, with the cookies appended to the request.
 
We can do this by having the malicious JavaScript insert an `<img>` tag with
`src` attribute set to the attacker's machine. When the JavaScript inserts the
`img` tag, the browser tries to load the image from the URL in the `src` field;
this results in an HTTP GET request sent to the attacker's machine. Your
JavaScript code should send the cookies to the port 41485 of the attacker's
machine, where the attacker has a TCP server listening to the same port. The
server can print out whatever it receives. The TCP server program is included
as `echoserv.py`, which is a python script, and can be **run outside the VM**.

**Be sure that there is only ever one instance of `echoserv.py` running at a time.** To check this, you can use `ps aux | grep echoserv` and kill all of the running processes, or add an exception handler to `echoserv.py` to handle the `errno.EADDRINUSE` error.
 
### Submission

Please submit a file called `task3.txt`. The grading will be done as
follows:

1. We will run the echo server on localhost on port 41485.
2. We will edit the brief description field acting as the user Alice
   using the message contents as specified by your `task3.txt`. We
   will use the *entire* contents of this file, so if you need to
   provide additional details, please do so in a separate file.
3. Then, when Boby opens this message, Boby's cookie should be printed
   by the echo server.

If for whatever reason you needed to test on a port other than 41485,
don't forget to change it back to 41485 once it's working! That's the
port we'll be using when grading.

### Points distribution
- 10 points: extracting Boby's cookie (all or nothing)

## Task 4: Session Hijacking using the Stolen Cookies (25 points)

After stealing the victim's cookies, the attacker can do whatever the victim
can do to the Elgg web server, including adding and deleting friends on behalf
of the victim, deleting the victim's posts, etc. Essentially, the attacker has
hijacked the victim's session. In this task, we will launch this session
hijacking attack, and write a program to remove one of the victim's friends.
 
To remove one of the victim's friends, we should first find out how a
legitimate user removes a friend in Elgg. More specifically, we need to figure
out what HTTP headers are sent to the server when a user removes a friend. A
screenshot of the request is provided to you, but you could easily get it
yourself (for instance, in Chrome, simply right-click and choose "Inspect",
then "Network", click on the resource for `remove?friend...` and look at the
Headers. From the contents, you can identify all the parameters in the request.
 
Once we have understood what the HTTP request for removing friends look like,
we can write a Java program to send out the same HTTP request. The Elgg server
cannot distinguish whether the request is sent out by the user's browser or by
the attacker's Java program. As long as we set all the parameters correctly,
and the session cookie is attached, the server will accept and process the
project-posting HTTP request. To simplify your task, we provide you with a
sample Java program that does the following:

1. Open a connection to web server.  
2. Set the necessary HTTP header information.  
3. Send the request to web server.  
4. Get the response from web server. 
 
**Note1:** Elgg uses two parameters `__elgg_ts` and
`__elgg_token`. Make sure that you set these parameters correctly for
your attack to succeed.  Also, please note down the correct guid of
the friend who needs to be added to the friend list.  You need to use
that guid in the program code for the attack to succeed.

**Note2:** We will compile the java program in the VM by running:

    javac --release=8 HTTPSimpleForge.java

You can then run the bytecode by running

    java HTTPSimpleForge  
 
### Submission

Please submit a file called `HTTPSimpleForge.java`.

**Input:** Your java program should read from an input file called
`HTTPSimpleForge.txt`. This filename should be hard-coded into your
program; it *will not* be passed on the command line. The first line
of the input file contains the `__elgg_ts` token (absolute value), the
second line contains the `__elgg_token` (absolute value) and the third
line would contain the Cookie HTTP header value:

    Elgg=<<cookie value>>

As an example:

    1402467511
    80923e114f5d6c5606b7efaa389213b3
    Elgg=7pgvml3vh04m9k99qj5r7ceho4

You can create a text file locally for testing out your code, however, you do
not need to submit this file as part of your submission. We will use our own
`HTTPSimpleForge.txt` file for checking.


### Grading

Here are the steps we will take when grading; you should follow the same steps
when testing your code.

1. Log in as Boby.

2. As Boby, add Alice as a friend.

3. Collect the token (`__elgg_token`), ts (`__elgg_ts`), and cookie (`Elgg`), and
write them to `HTTPSimpleForge.txt`

4. Compile your java program (from outside the VM) via `javac --release=8 HTTPSimpleForge.java`

5. Run your executable (also from outside the VM) via `java HTTPSimpleForge`

6. Check Boby's friends, and ensure that Alice is no longer a friend.

Make sure you include the correct guid and parameters in the code for the above
scenario to execute properly.
 
###  Points distribution
- 25 points: Remove Alice as a friend (all or nothing)

# CSRF Attack (20 points)

Your goal in these tasks is to find ways to exploit a Cross-Site Request Forgery
vulnerability.

Steps for running docker image:

1. Start the server by running the following from within the QEMU VM:

   ```
   docker run -d -p 41483:80 -v "$(pwd):/var/www/CSRF/Attacker" --name csrf_server csrf
   ```

2. You can access the server in your browser (outside the VM) at

    http://localhost:41483/

This is running a slightly different version of Elgg, but has the same users
and credentials as in the XSS tasks.
 
## Task 5: CSRF Attack using GET Request (20 points)
 
In this task, we need two people in the Elgg social network: Alice and Boby.
Alice wants to become a friend to Boby, but Boby refuses to add Alice to his
Elgg friend list. Alice decides to use the CSRF attack to achieve her goal. She
sends Boby a URL (via an email or a posting in Elgg); Boby, curious about it,
and clicks on the URL. Pretend that you are Alice, and think about how you can
construct the contents of the web page, so as soon as Boby visits the web page,
Alice is added to the friend list of Boby (assuming Boby has an active session
with Elgg).

To add a friend to the victim, we need to identify the Add Friend HTTP request,
which is a GET request. In this task, you are not allowed to write JavaScript
code to launch the CSRF attack. Your job is to make the attack successful as
soon as Boby visits the web page, without even clicking on the page (hint: you
can use the `img` tag, which automatically triggers an `HTTP GET` request).

Whenever the victim user visits the crafted web page in the malicious site, the
web browser automatically issues an `HTTP GET` request for the URL contained in
the `img` tag. Because the web browser automatically attaches the session
cookie to the request, the trusted site cannot distinguish the malicious
request from the genuine request and ends up processing the request,
compromising the victim user's session integrity.

Observe the request structure for adding a new friend and then use this to
forge a new request to the application. When the victim user visits the
malicious web page, a malicious request for adding a friend should be injected
into the victim's active session with Elgg.
 
### Submission

You are required to submit a file named `task5.html`. When a victim user named
Boby is logged in, and visits the attacker website `localhost:41483/task5.html`
in another tab, Alice should be added as a friend to Boby's Friend List.
 
To test this, you will need to place the `task5.html` file under the directory
`/var/www/CSRF/elgg/` in the docker container. You can do this by running the
following from within the QEMU VM (assuming `task5.html` has already been
copied into the VM):
  
    docker cp task5.html csrf_server:/var/www/CSRF/elgg

**Tip:** Your browser may not refresh on its own. You might need to
press the reload/refresh button to reload the page, to see if Alice is
added as a friend to Boby's account.

**Recall** that we will not be accessing your docker containers; you need
to include `task5.html` in the git repository we forked for you.

### Points distribution
- 20 points: Successfully added Alice as a friend via CSRF

# Checker scripts

 We are providing some basic checker scripts to ensure that
your project submission conforms to our grading scripts' expected formatting.
It is very important that you ensure your submissions matches our expected
inputs, or else you may lose a considerable amount of points. The checker
scripts are the best way to ensure this.

To run the checker scripts:
- Go to the base directory where your project files are (not into the
  `checkers/` directory itself).
- Ensure that the corresponding docker container is running (e.g., if you are
  testing your SQL injection tasks, make sure that you are running the `sqli`
  container).
- Run the relevant script via `bash checkers/task<N>.sh` (where `<N>` is the
  number of the task you wish to validate).

Please note that these scripts are NOT running the full gamut of tests that our
grading scripts will. These are just to verify that we are recognizing your
inputs appropriately. You should not rely on the checker scripts for all of
your testing.
