# DMU Simulator v0.4.1

This maintenance release fixes DMU P5 loading in both solo and multiplayer sessions. P5 now ships without dependencies on resources excluded from the DMU client package.

This release also includes experimental multiplayer support through a lightweight dedicated relay. Each player runs the simulation locally while the relay coordinates player positions, roles, pause state, restarts, and session configuration.

> [!WARNING]
> Multiplayer is still experimental. Connections use unencrypted UDP, including the session password when one is configured. Do not reuse a sensitive password.

## Downloads

- **Windows client:** `dmu-sim-v0.4.1-windows.zip`
- **Windows relay:** `dmu-relay-v0.4.1-windows.zip`
- **Linux x86_64 relay:** `dmu-relay-v0.4.1-linux-x86_64.zip`

Keep each executable and its accompanying `.pck` file together in the same directory.

## Running the Relay

The relay uses UDP port `7000` by default. To host over the internet, allow this port through the host firewall and forward UDP port `7000` to the relay machine.

### Windows

Open PowerShell in the extracted `server-windows` directory:

```powershell
.\dmu-server.exe --server --port 7000
```

### Linux

Open a terminal in the extracted `server-linux` directory:

```bash
chmod +x ./dmu-server-linux.x86_64
./dmu-server-linux.x86_64 --server --port 7000
```

### Password-Protected Session

Add `--password` to either command:

```text
--password your-password
```

Windows example:

```powershell
.\dmu-server.exe --server --port 7000 --password your-password
```

Linux example:

```bash
./dmu-server-linux.x86_64 --server --port 7000 --password your-password
```

The password is transmitted over unencrypted UDP. Use a temporary password that is not shared with any other account or service.

### Restricting Connections by IP

Use `--allow-ip` to restrict which public IP addresses may connect:

```text
--allow-ip 203.0.113.10
```

Multiple addresses can be separated by commas:

```text
--allow-ip 203.0.113.10,198.51.100.20
```

## Connecting

1. Start the relay.
2. Launch `dmu-sim.exe`.
3. Open the multiplayer connection screen.
4. Enter the relay address, UDP port, and password if one was configured.
5. Select an available role and connect.
6. Restart the encounter after everyone has joined so all clients begin synchronized.

## Known Multiplayer Issues

- Other players' movement animations do not display correctly. Their positions are synchronized, but their movement animation may appear incorrect.
- The boss cast bar continues progressing visually while the session is paused. The underlying mechanic timer remains paused and resumes correctly.
- All network traffic uses unencrypted UDP. This includes the session password.
- Mechanics and session timing are still client-authoritative.
- Restart the encounter after new players connect so all clients begin synchronized.
- Joining during an encounter may leave the new player out of sync until the group restarts.