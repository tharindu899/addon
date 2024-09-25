To automatically switch to and detect your new VPN proxy configuration with hostname `100.111.65.142` and port `8080` on Fedora, you can use the following approach to set up auto-detection and integration of the VPN into your system's proxy settings.

### Steps for Setting Up Automatic VPN Proxy Detection in Fedora (KDE):

#### 1. **NetworkManager VPN Integration**

Fedora’s **NetworkManager** handles connections (including VPN and proxies) seamlessly. You can integrate this VPN configuration into NetworkManager to make Fedora automatically detect and apply the VPN proxy when connected.

##### a. **Add Your VPN to NetworkManager**

If you haven’t already configured the VPN, follow these steps to add it:

1. **Install VPN Plugin** (if necessary):
   - If you’re using OpenVPN, PPTP, or any other VPN, install the appropriate plugin for NetworkManager.
     ```bash
     sudo dnf install NetworkManager-openvpn-gnome
     ```
   - You can replace `openvpn` with your VPN type if it's different (e.g., `NetworkManager-pptp`).

2. **Configure VPN in KDE**:
   - Open **System Settings** → **Network**.
   - Click **Connections** → **Add New Connection**.
   - Select **VPN** and follow the wizard to add your VPN with the appropriate credentials.

3. **Connect to the VPN**:
   - Once added, connect to the VPN using **NetworkManager** (either through KDE's network applet or in System Settings).

##### b. **Configure the Proxy for VPN**

You can configure the proxy to automatically apply when the VPN is active by modifying the VPN connection settings.

1. Open **System Settings** → **Network**.
2. Select your **VPN Connection** and click **Edit**.
3. Go to the **Proxy** tab.
4. Set the proxy as follows:
   - **Proxy Method**: **Manual**.
   - **HTTP Proxy**: `100.111.65.142`.
   - **Port**: `8080`.
   - Optionally, configure additional proxy settings for HTTPS, FTP, and SOCKS if required.
   
5. **Save** the changes.

Now, when you connect to this VPN, Fedora will automatically route traffic through this proxy.

#### 2. **Auto-Detect VPN Connectivity & Rotate Proxies**

If you want Fedora to automatically rotate between multiple proxies or detect the current connection (VPN or otherwise), you can achieve this by scripting or using an external tool like **NetworkManager Dispatcher**. Here's how:

##### a. **Using NetworkManager Dispatcher for Auto-Detection**
The **NetworkManager Dispatcher** is a service that runs scripts when network interfaces go up or down, allowing you to dynamically configure proxies based on connection.

1. **Create a Dispatcher Script**:
   Create a script that checks if the VPN is connected, and if so, applies the proxy configuration. 

   ```bash
   sudo nano /etc/NetworkManager/dispatcher.d/99-vpn-proxy
   ```

2. **Script Content**:
   Add the following content to detect the VPN connection and apply the proxy settings dynamically:

   ```bash
   #!/bin/bash
   # NetworkManager Dispatcher script to apply proxy when VPN is connected
   
   INTERFACE=$1
   STATUS=$2

   if [ "$STATUS" = "up" ]; then
       # Check if the VPN is active
       VPNCONN=$(nmcli con show --active | grep vpn | awk '{print $1}')

       if [ ! -z "$VPNCONN" ]; then
           # If VPN is active, set proxy to 100.111.65.142:8080
           gsettings set org.gnome.system.proxy mode 'manual'
           gsettings set org.gnome.system.proxy.http host '100.111.65.142'
           gsettings set org.gnome.system.proxy.http port 8080
           gsettings set org.gnome.system.proxy.https host '100.111.65.142'
           gsettings set org.gnome.system.proxy.https port 8080
       else
           # If no VPN is active, disable proxy
           gsettings set org.gnome.system.proxy mode 'none'
       fi
   fi
   ```

3. **Make the Script Executable**:
   Ensure the script is executable by running:
   ```bash
   sudo chmod +x /etc/NetworkManager/dispatcher.d/99-vpn-proxy
   ```

4. **Restart NetworkManager**:
   Restart NetworkManager to apply the changes:
   ```bash
   sudo systemctl restart NetworkManager
   ```

#### 3. **Test the Auto-Detection**

1. **Connect to your VPN**.
   - When you connect to your VPN (either manually or automatically when the mobile VPN connects), the script should detect it and automatically configure the proxy.

2. **Check if Proxy is Applied**:
   - You can verify that the proxy is being used by running the following command:
     ```bash
     gsettings get org.gnome.system.proxy.http host
     ```

3. **Rotate Between VPNs and Proxies**:
   - If you have multiple VPNs with different proxies, you can enhance the script to rotate between them based on which VPN connection is active. Simply modify the script to check for the VPN's name and apply the appropriate proxy.

---

### Conclusion:
By integrating your VPN into **NetworkManager** and using **NetworkManager Dispatcher** for auto-detection, Fedora will automatically apply the correct proxy (`100.111.65.142:8080`) whenever the VPN is active. This allows seamless transitions between VPNs and proxies without manual intervention.

Let me know if you need more detailed adjustments or troubleshooting for specific steps!


# -----------------

If you want to set up a **proxy rotation** between your HTTP proxies (`100.111.65.142:8080`, `168.192.8.102:8080`) and your SOCKS5 proxy (`26.26.26.1:10808`), you can use **Proxychains** to achieve this. Proxychains supports rotating between different proxies in a chain and automatically using the available proxy when one fails.

Here’s how to configure proxy rotation in Fedora:

### 1. **Install Proxychains**

First, if you don’t have Proxychains installed, you need to install it:

```bash
sudo dnf install proxychains
```

### 2. **Configure Proxychains for Proxy Rotation**

Edit the `proxychains.conf` file to add your proxies and configure the rotation:

1. **Open the Proxychains Configuration File**:
   ```bash
   sudo nano /etc/proxychains.conf
   ```

2. **Edit the Configuration**:
   - In the configuration file, find the section where the proxy list starts (under `[ProxyList]`).
   - You need to uncomment (remove `#`) from `dynamic_chain` for proxy rotation and ensure that `strict_chain` is commented out.
   
   **Example:**
   ```
   # The option below identifies how the ProxyList is treated.
   dynamic_chain
   #strict_chain
   ```

3. **Add Your Proxies to the List**:
   In the `[ProxyList]` section, list your HTTP and SOCKS5 proxies like this:

   ```bash
   [ProxyList]
   # Add your proxies below

   http 100.111.65.142 8080
   http 168.192.8.102 8080
   socks5 26.26.26.1 10808
   ```

4. **Save and Exit**:
   - Save the changes (`Ctrl + O` to write, `Ctrl + X` to exit).

### 3. **How Proxychains Rotation Works**

When you use **dynamic_chain**, Proxychains will automatically rotate between proxies. This means:

- If a proxy is unavailable (for example, the HTTP proxy fails), Proxychains will try the next one in the list.
- It will skip dead proxies and attempt to connect via the next available proxy in the chain.

### 4. **Testing the Configuration**

To test the proxy rotation, you can run commands like this:

```bash
proxychains curl http://example.com
```

### 5. **Using Proxychains with Applications**

You can use Proxychains with any application by prefixing the command with `proxychains`. For example:

- To open Firefox using the rotating proxy list:
  ```bash
  proxychains firefox
  ```

- To download a file using `wget` with the proxies:
  ```bash
  proxychains wget http://example.com/file.zip
  ```

### 6. **Advanced Options: Auto-detect Proxy Connectivity**

If you want to detect the fastest or most responsive proxy, you can script a solution that checks which proxy is active and connects based on that. However, **Proxychains dynamic_chain** will handle most scenarios of failing or unreachable proxies and automatically switch to the next working one in the list.

---

### Conclusion

By configuring **Proxychains** with the `dynamic_chain` option, you can automatically rotate between the HTTP proxies (`100.111.65.142:8080`, `168.192.8.102:8080`) and the SOCKS5 proxy (`26.26.26.1:10808`). Proxychains will skip non-working proxies and use the first available one, ensuring that your applications always have an active proxy.

Let me know if you need further adjustments!




## -------------------

To route your **entire system traffic** through a proxy in Fedora (KDE), including all applications and terminal commands, you can configure system-wide proxy settings. There are a few methods to achieve this, depending on your needs and the type of proxy (HTTP, HTTPS, SOCKS5) you want to use. Here's how to do it.

### 1. **Method 1: Set System-Wide Proxy in NetworkManager**

This is the simplest method if you want all applications, browsers, and terminal commands to route through a proxy automatically.

#### Steps:
1. **Open Network Settings (KDE):**
   - Go to **System Settings** → **Network** → **Connections**.
   - Select your active network connection (Wi-Fi or Ethernet), then click **Edit**.

2. **Configure Proxy Settings:**
   - Go to the **Proxy** tab.
   - Set **Proxy Method** to **Manual**.

3. **Set the Proxy Details:**
   - For **HTTP**, input your HTTP proxy IP (e.g., `100.111.65.142`) and port (`8080`).
   - For **HTTPS**, input the same or different proxy if you want.
   - If you're using a **SOCKS5 proxy**, input the SOCKS5 proxy (`26.26.26.1:10808`).

   Example:

   | Proxy Type | Host              | Port |
   |------------|-------------------|------|
   | HTTP       | `100.111.65.142`  | `8080` |
   | HTTPS      | `100.111.65.142`  | `8080` |
   | SOCKS5     | `26.26.26.1`      | `10808` |

4. **Save Changes**:
   - Click **Apply** or **Save**.

Now, your entire network connection will route through the specified proxy for all system traffic.

### 2. **Method 2: Configure Proxy Environment Variables**

For system-wide proxy settings on a per-user basis, you can set proxy environment variables in your shell configuration files (e.g., `.bashrc` or `.zshrc`).

#### Steps:
1. **Open Terminal**:
   Open your terminal and edit your shell configuration file (`.bashrc` or `.zshrc`):

   ```bash
   nano ~/.bashrc
   ```

2. **Add Proxy Environment Variables**:
   Add the following lines for HTTP, HTTPS, and SOCKS5 proxy configuration:

   ```bash
   export http_proxy="http://100.111.65.142:8080"
   export https_proxy="http://100.111.65.142:8080"
   export ftp_proxy="http://100.111.65.142:8080"
   export socks_proxy="socks5://26.26.26.1:10808"
   export no_proxy="localhost,127.0.0.1"
   ```

   This will configure proxy settings for all terminal-based applications like `curl`, `wget`, `apt`, etc.

3. **Apply the Changes**:
   To apply these changes, run:

   ```bash
   source ~/.bashrc
   ```

Now, all terminal commands will automatically route through your configured proxy settings.

### 3. **Method 3: Proxychains for Full System Routing (Command-Line Apps)**

If you want all command-line applications to go through a proxy (but not necessarily all system GUI apps), you can use **Proxychains**.

#### Steps:

1. **Install Proxychains**:

   ```bash
   sudo dnf install proxychains
   ```

2. **Edit Proxychains Configuration**:

   Edit the Proxychains configuration file to include your proxy details:

   ```bash
   sudo nano /etc/proxychains.conf
   ```

   Add your proxies at the bottom of the file:

   ```bash
   [ProxyList]
   http 100.111.65.142 8080
   http 168.192.8.102 8080
   socks5 26.26.26.1 10808
   ```

3. **Set Proxy Mode**:
   - Use `dynamic_chain` mode for automatic failover between proxies (uncomment `dynamic_chain`).
   - Use `strict_chain` mode to enforce using the proxies in the exact order listed.

4. **Route Commands Through Proxychains**:
   Run any command through Proxychains by prefixing it:

   ```bash
   proxychains firefox
   ```

   This will launch Firefox through your proxy.

### 4. **Method 4: Configure Proxy in KDE System Settings for Applications**

If you want to configure a proxy for all applications (GUI) and KDE-based apps (like Dolphin, Konsole, etc.):

1. **Open KDE System Settings**:
   - Go to **System Settings** → **Network** → **Settings**.
   - Select **Proxy**.

2. **Manual Proxy Configuration**:
   - Set **HTTP Proxy**, **HTTPS Proxy**, and **SOCKS5 Proxy** here.
   - You can enter the same proxy details as before.

3. **Apply Settings**:
   - Click **Apply**.

This will ensure that all KDE-based applications use the proxy.

### 5. **Method 5: Use a VPN with Proxy Setup (Mobile VPN)**

If your mobile device's VPN connection is used as a hotspot and the VPN provides a proxy (`100.111.65.142:8080`), you can combine the proxy with a VPN.

1. **Connect to Your Mobile VPN Hotspot**.
2. **Configure the Proxy in Fedora (using any of the methods above)**.
3. **Ensure VPN Routes Traffic**.
   - The VPN should already route your traffic through its network.
   - The proxy settings will further ensure that Fedora sends data through the VPN and then through the proxy.

### Summary

To route **all traffic** through proxies on Fedora KDE:

1. **Use NetworkManager** to set proxies for your network connections.
2. **Set environment variables** for terminal-based apps (in `.bashrc`).
3. Use **Proxychains** for specific command-line routing.
4. **KDE System Settings** for GUI apps to use proxies.
5. Combine with your **mobile VPN hotspot** for even more anonymity and protection.

Let me know if you need additional help!