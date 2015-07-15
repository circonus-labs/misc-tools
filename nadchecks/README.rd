This is a tool to be used with circonus-labs nad.  Running a DTrace command directly from a script would possibly have some unpleasant effects where the command could hang up nad until it can return a result.

To solve this a intrstat is run for 5 seconds in a infinite loop and writes out the results to a file.  One process is run for each CPU core you want to monitor.

You must create the /var/log/intrst directory first and then run each intrstatresult script with nohup.

The intrruptbycpu.sh script it dropped into the node-agent.d directory and fetches the contents of those files for collection into Circonus.

There is probably a better way to do this.  Please contribute otherwise.
