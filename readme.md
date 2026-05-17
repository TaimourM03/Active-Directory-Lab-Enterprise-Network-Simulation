# 🖥️ Active Directory Lab — Enterprise Network Simulation 

## 📌 Technologies Used
- **Active Directory Domain Services (AD DS)**
- **DNS**
- **DHCP**
- Windows Server 2022
- Windows 11
- VMware Workstation Pro
- RBAC
- Group Policy (GPO/GPP)
- NTFS
- NTFS Permissions
- ABE
- application control / endpoint hardening
- SMB Shares
- PowerShell Scripts

---
## 🧾 1. Project Overview
---
This project simulates a small-scale enterprise IT infrastructure using a virtualized environment based on Windows Server.

It demonstrates how core services such as Active Directory, DNS, and DHCP are deployed, configured, and secured in a corporate network.

The lab focuses on identity management, access control, and policy enforcement, following real-world administrative practices.


### 🎯 Objectives:
- Centralize authentication using Active Directory
- DNS Configuration for internal name resolution
- Automate IP assignment using DHCP
- Apply security and configuration policies via GPOs
- Implement access control using groups and NTFS permissions
- Automate network drive mapping for shares using Group Policy Preferences
- Simulate a structured enterprise environment



### 🏗️ Architecture:
```
┌───────────────────────┐ 
│    Windows Server     │ 
│  (Domain Controller)  │                                  ┌───────────────────────┐ 
│-----------------------│      ─────────────────────>      │    Windows Client     │
│                       │                                  │    (Domain Joined)    │ 
│ AD DS  | DNS  |  DHCP │                                  └───────────────────────┘
└───────────────────────┘

VM-1: Windows Server                                     VM-2: Windows Client (Windows 11)                    
- Role: Domain Controller                                - Role: Domain-joined workstation
- Services:                                              - Purpose:
    1. Active Directory Domain Services (AD DS)             1. Authentication testing
    2. DNS Server                                           2. GPO validation
    3. DHCP Server                                          3. Resource access verification

```

### 👥 Active Directory Design:
Schema with key concepts implemented:
- Organizational Units (OUs)
- Security Groups
- User Accounts
- Role-based access control (RBAC)
```
taicorp.local
│
├── OU=Administration
│   ├── Users
│   │   └── Taimour (General Manager)
│   └── Groups
│       └── GRP_Administration
│
├── OU=IT
│   ├── Users
│   │   ├── David Martinez Ceacero (IT Support)
│   │   ├── Maria Aznar Molina (Server Admin)
│   │   └── Carlos Lopez Garcia (Domain Admin)
│   └── Groups
│       └── GRP_IT
│
├── OU=Sales
│   ├── Users
│   │   ├── Jaime Ortiz Burgos (Sales Director)
│   │   └── Clara Lopez Masnou (Sales Rep)
│   └── Groups
│       └── GRP_Sales
│
├── OU=Marketing
│   ├── Users
│   │   └── Lucia Pastor Ruiz (Marketing Specialist)
│   └── Groups
│       └── GRP_Marketing
│
└── OU=Computers
    ├── PC-ADMIN1
    ├── PC-ADMIN2
    ├── PC-IT1
    ├── PC-IT2
    ├── PC-SALES1
    ├── PC-SALES2
    ├── PC-MKT1
    └── PC-MKT2

```



### 📁 Shared Resources & Permissions (Shares):
Access is controlled using NTFS permissions applied to security groups (GRP_*). 

Each department has isolated access to its own resources.

IT department provides infrastructure support but does not automatically access business data.

Share permissions are kept based on the **Least privilege principle** (Each department only accesses its own data.)

We will also ensure users only see content they are authorized to view, by applying **Access-Based Enumeration (ABE)**, which is a Windows feature that hides files and folders from users who do not have explicit NTFS permissions to access them.

Users will not manually map network shares. Instead, network drives will later be automatically deployed using Group Policy Preferences (GPP) for **automatic network shares mapping**, depending on the user's department and OU membership.
<br>

| Resource                    | Administration | IT (Support/Admin) | Sales          | Marketing      |
|----------------------------|---------------|--------------------|----------------|----------------|
| `\\Server\Administration`  | ✔️ Full Control | ❌ No Access        | ❌ No Access    | ❌ No Access    |
| `\\Server\IT`              | ❌ No Access    | ✔️ Full Control     | ❌ No Access    | ❌ No Access    |
| `\\Server\Sales`          | ❌ No Access    | ✔️ Support (Modify) | ✔️ Read/Write   | ❌ No Access    |
| `\\Server\Marketing`      | ❌ No Access    | ✔️ Support (Modify) | ❌ No Access    | ✔️ Read/Write   |



### 🛡️ Group Policy Objects (GPOs):
|Department|Users| Main GPOs | Control Panel | CMD / PowerShell | USB |
|---|---|---|---|---|---|
| 👔 Administration | Taimour | GPO_Admin | ✔️ | ✔️ | ✔️ |
| 💻 IT | David, Maria, Carlos | GPO_IT | ✔️ | ✔️ | ✔️ |
| 💼 Sales | Jaime, Clara | GPO_Sales | ❌ | ⚠️ | ✔️ |
| 📢 Marketing | Lucia | GPO_Marketing | ❌ | ⚠️ | ✔️  |


### 🔐 Security Considerations

- Principle of Least Privilege enforced through security groups  
- GPO restrictions reduce the attack surface  
- NTFS permissions enforce strict access control  
- Administrative privileges limited to IT department  
- Basic auditing enabled for monitoring user activity  
- Access-Based Enumeration (ABE) prevents users from viewing unauthorized folders
- Centralized drive deployment reduces user configuration errors


### 🛠️ Implementation Checklist

#### 👔 Administration
- [ ] Create `GPO_Admin`
- [ ] Allow access to Control Panel
- [ ] Allow software installation
- [ ] Allow unrestricted use of CMD / PowerShell
- [ ] Allow use of USB
- [ ] Do not apply desktop restrictions
- [ ] Link to OU=Administration

#### 💻 IT
- [ ] Create `GPO_IT`
- [ ] Allow full access to administrative tools
- [ ] Allow PowerShell and CMD without restrictions
- [ ] Enable security auditing (logs)
- [ ] Allow USB usage
- [ ] Allow execution with administrative privileges
- [ ] Link to OU=IT

#### 💼 Sales
- [ ] Create `GPO_Sales`
- [ ] Block Control Panel
- [ ] Block software installation
- [ ] Restrict CMD / PowerShell (limited use)
- [ ] Allow USB use
- [ ] Block changes to system settings
- [ ] Link to OU=Sales

#### 📢 Marketing
- [ ] Create `GPO_Marketing`
- [ ] Block Control Panel
- [ ] Allow specific software (design / browser)
- [ ] Restrict CMD / PowerShell
- [ ] Allow USB usage
- [ ] Block network and system changes
- [ ] Link to OU=Marketing

---  

<br></br>

---
## 🖥️ 2. Virtual Machine Setup
---
Objectives:
- [ ] Create VM1: Windows Server
- [ ] Create VM2: Windows 11 (client)
- [ ] Allocate Resources (CPU, RAM, disk)
- [ ] Configure networking (NAT / Internal Network)
---
For the virtualization of the machines we will: 
- Use VMware Workstation Pro (25H2u1)
- Download [Windows Server 2022](https://www.microsoft.com/es-es/evalcenter/download-windows-server-2022) ISO for the Server
- Download [Windows 11 23H2](https://www.microsoft.com/es-es/software-download/windows11arm64) ISO for the client

For the network adapters, We will use 2 adapters on the server and 1 on the client:
|       VM        |   Adapter 1         |             Adapter 2            |
| :-------------: | :-----------------: | :-----------------------------: |
|     Server      |        NAT          | Host-Only (Internal Network)    |
|     Client      |     Host-Only       |               ❌               |

Why are we using these adapters?
```
1. NAT (🛜 Server gets internet): 
    - Shares your real internet connection, which we need in server to:              INTERNET
        1. Download updates                                                             │
        2. Install roles/features                                                    [ NAT ]
        3. Sync time (important for Kerberos)                                           │
        4. Possibly download RSAT tools or patches                           ┌────────Server─────────┐
                                                                             │   Domain Controller   │
                                                                             │    AD + DNS + DHCP    │
2. Host-Only (🔒 Internal Network):                                          └──────────────────────┘
    - Creates a completely isolated network between VMs + host                           │
    - No internet connection                                                     [ HOST-ONLY LAN ]
    - Server needs access to manage the internal domain network                          │
    - Clients needs to:                                                            ┌──CLIENT───┐
        1. Get IP from DHCP server                                                 │ Windows 11│
        2. Use internal DNS                                                        └───────────┘ 
        3. Join domain                                                             
        4. Receive GPOs
```
Given the context, we will start by creating the virtual networks in VMWare:

<img src="/screenshots/1.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />   
<img src="/screenshots/2.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />   

Note that the host-only adapter has DHCP disabled, since the server will host it.

We have created our first machine SRV-DC01, with the following hardware:
<img src="/screenshots/3.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />   

We also created the client machine CLT-W11-01, with the following hardware:
<img src="/screenshots/4.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />   

We can then start the machines and install the Operating Systems with the Virtual Wizard:
<img src="/screenshots/5.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />   
<img src="/screenshots/7.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />   
<img src="/screenshots/10.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />   
<br><br>

<img src="/screenshots/6.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />   
<img src="/screenshots/8.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />   
<img src="/screenshots/9.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />   
<br>
Both machines have their respective OS installed successfully, 
but we still have to change the hostname:
<img src="/screenshots/30.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
Also in the client:
<img src="/screenshots/31.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />


Now it's time to configure the network and connectivity. 



---  

<br></br>

---
## 🌐 3. Network Configuration
---
- [x] Assign static IP to server
- [x] DNS Configuration
- [x] Test connectivity between VMs
---  
We will procede by applying a static IP address to the server, it will have the following network settings:
- IP:        **192.168.115.10**
- Mask:      255.255.255.0
- Gateway:    (empty)
- DNS:        192.168.115.10
 
To do so, we have to go to: 
***Control Panel*** → ***Network Adapter*** → ***Ethernet 1*** (Since it's the one that has the Host-Only adapter) → ***IPV4***
<img src="/screenshots/11.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />   

Notice how we have also set the DNS server IP to the server's IP, because the server will also host DNS petitions.
<br>

Now we are also gonna set a **temporary** static IP address to the client, since the DHCP server is not set yet, it will have the following network settings:
- IP:        **192.168.115.20**
- Mask:      255.255.255.0
- Gateway:    (empty)
- DNS:        192.168.115.10 

<img src="/screenshots/12.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" /> 
<br><br>

Finally, we have to realease the old network configuration and apply the new one, to do so we can disable and re-enable the ethernet adapters in both machines:
<img src="/screenshots/13.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" /> 

Once we have applied the new network configuration, we can check if the changes have been applied successfully, by executing the command, **ipconfig**:
<img src="/screenshots/14.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" /> 
<img src="/screenshots/15.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" /> 

The static IPs have been set successfully, we can check connectivity between machines, by executing the command, **ping** ***<ip_address>***:
<img src="/screenshots/16.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<img src="/screenshots/17.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<br>
We have connection between VMs, let's proceed to configure and install the server main roles.  

<br></br>

---
## 🏗️ 4. Install Roles in Windows Server
---
- [ ] Install Active Directory Domain Services (AD DS)
- [ ] Install DNS Server
- [ ] Install DHCP Server
---  
Using the Server Manager, we are going to add the roles:
<img src="/screenshots/18.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<img src="/screenshots/19.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<img src="/screenshots/20.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

Once the installation is finished, we have to restart the server, and finish the configuration warnings that will pop up in the Server Manager:
<img src="/screenshots/21.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

We have finish the configuration of our Domain, which we will continue at the next point. 

<br></br>

---
## 🏢 5. Domain Controller Promotion
---
- [ ] Create new forest (taicorp.local)
- [ ] Promote server to Domain Controller
---  
After installing AD DS, in Server Manager will pop up a Active directory configuration, which we will complete now. First, we will add a new forest with our root domain, **taicorp.local**:
<img src="/screenshots/22.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

Once the installation has completed, the server will restart, and we can see that the domain has been created successfully:
<img src="/screenshots/23.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<img src="/screenshots/24.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

We can now proceed to the following point, to configure DNS.

<br></br>

---
## 🌍 6. DNS Configuration
---
- [ ] Verification of forward and reverse lookup zone
- [ ] Test name resolution
---  
We can test the forward lookup of our tree:
<img src="/screenshots/25.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

But, for the reverse lookup, first we need to configure a reverse lookup zone, for that, we have to open the **DNS Manager** and create a new Reverse lookup zone:
<img src="/screenshots/26.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

Now we have to create the pointer record:
<img src="/screenshots/27.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<img src="/screenshots/28.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

We can now reverse lookup:
<img src="/screenshots/29.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

Also from the client:
<img src="/screenshots/32.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

<br></br>

---
## 📡 7. DHCP Configuration
---
- [ ] Create scope
- [ ] Define IP range
- [ ] Configure gateway and DNS
- [ ] Authorize DHCP
- [ ] Test automatic IP assignment
---  
Before starting enabling DHCP, we have to complete some basic DHCP configuration after the DHCP role has been installed in the server. 
<img src="/screenshots/33.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

Now we can start configuring our DHCP server, for that go to: 
***Server Manager → Tools → DHCP***
<img src="/screenshots/34.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

Now we can set a range of IP addresses, by right clicking on ***IPv4 → New Scope***:
<img src="/screenshots/35.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

<img src="/screenshots/36.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

In our case, we have decided to follow the following IP network scope:
- Start IP: 192.168.115.100
- End IP:   192.168.115.200

We will maintain a clean separation of IPs, so:
- 1–50 = reserved (servers, DC, infrastructure)
- 100–200 = clients
<br>

We have to also set the DNS server for the network:
<img src="/screenshots/38.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<br>

Now we can go into the client, and see if our DHCP server is correctly working.
1. First let's check the current IP (static):
   <img src="/screenshots/15.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" /> 
<br>
2. Let's switch the adapter network settings, from the static IP server to dynamic and also the DNS server:
   <img src="/screenshots/39.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" /> 
<br>
3. Finally, we can check the new network setting applied:
   <img src="/screenshots/40.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" /> 

Now that we have the basic network services running, we can start configuring our Active Directory, proceeding to the next point.

Notice that we didn't configure a Default Gateway, which is a mistake.  
We can apply it by, going into ***Server Manager → Tools → DHCP → IPv4 → Your Scope → Scope Options*** then right click into **Configure Options**. 
There, we have to apply a new scope option, **003 Router** with the IP address (server):
<img src="/screenshots/60.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" /> 

Once done, we can reset the ethernet 1 adapter in the client machine, to get the new configuration, and then we can check that the Default Gateway has been set:
<img src="/screenshots/61.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" /> 

<br></br>

---
## 👥 8. Active Directory Setup
---
- [ ] Create OUs
- [ ] Create users
- [ ] Create security groups
- [ ] Assign users to groups

---  
To manage the OUs of our active directory we can go into the the Server Manager, and then to ***Tools → Active Directory Users and Computers***
<img src="/screenshots/41.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

<br>

Now we're gonna create all the departments, in Organizational Units, for that, right click in the domain ***taicorp.local → New → Organizational Unit***:
<img src="/screenshots/42.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

Now we have all the departments created, we've also create two sub-OUs inside "Users" and "Groups":
<img src="/screenshots/44.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

We have decided to follow this structure, since it allows us to:
- Apply GPOs per department
- Separate users from groups (clean design)
- Scale like a real company

<br>

Now, to create groups, we're gonna go into every "Groups" OU inside the main departments OU, and right click ***New → Group***:
<img src="/screenshots/45.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

All the groups have been created:
<img src="/screenshots/46.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<br>

It's time to create the users, although this will be done kind of differently.

The Departments and Groups of a Enterprise, are not a lot, meaning that they can be created inside AD manually without spending much time.

But when talking about Users, this is totally the opposite. Most Business handle a lot of workers, this makes **manually creating the users inside Active Directory a bad idea**, since it would take a lot of time. 

To fix this, we can use **Powershell automation** to create all the users for us. Organizations usually store the name of all the workers and other data about them, in .xlsx tables (excel), which can later be exported as CSV, Json and other formats.
For example, a basic excel table that includes all the workers of taicorp, their departments and Role:
<img src="/screenshots/52.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<img src="/screenshots/51.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<img src="/screenshots/55.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<br>

We have created a basic [Script](ADUserCreationScript/UserCreation.ps1) that automates the provisioning of Active Directory users using data imported from a CSV file. 
For each entry, it parses the user’s full name into first name and surname(s), generates a valid SamAccountName, verifies that the account does not already exist, and dynamically determines the correct Organizational Unit (OU) based on the user’s department.

It then creates the Active Directory account with the appropriate identity attributes:
- GivenName
- Surname 
- DisplayName
- UserPrincipalName 
- Temporary password (must be changed at first login, **temp123!**) 
- places the account inside the corresponding departmental OU. 

<img src="/screenshots/53.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<br>

Finally, the script implements Role-Based Access Control (RBAC) by automatically adding the user to the security group associated with their department.

<img src="/screenshots/56.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<br>

We can execute the script, by placing it in the same directory as the **users.csv** file and executing the script inside a Windows Powershell Terminal (**.\UserCreation.ps1**):
<img src="/screenshots/54.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<br>

Now we can check that the users have been created successfully and also check properties:
<img src="/screenshots/57.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

For example, Jaime Ortiz Burgos' properties indicates us that our script worked:
<img src="/screenshots/58.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

We can also check that he has been added to the GRP_Sales group:
<img src="/screenshots/59.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

Now that we have all the users created in the Active Directory, we can test to log into them using our Client machine.

<br></br>

---
## 💻 9. Join Client to Domain
---
- [ ] DNS Configuration
- [ ] Join client to domain
- [ ] Test login with domain user

---  
First let's make sure that the DNS configuration is applied and works in the client. 
If we execute **ipconfig /all** we can see the DNS server:
<img src="/screenshots/62.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

Also a quick command to check the DNS resolutions are being handled and done:
<img src="/screenshots/63.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<br>

Now, we can join the client to the domain, to do that, go to: 
***Settings → System → About → Domain or workgroup → Rename this PC (advanced) → Domain*** 
Then, introduce the new Domain, in this case, taicorp.local:
<img src="/screenshots/64.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

It will ask for Credentials prompt, and we will have to access a Domain Admin, in our case, we will access Administrator's account:
<img src="/screenshots/65.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

Then we will get a success window, and it will restart the system to apply changes:
<img src="/screenshots/66.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<br>

Finally, let's test the login from our client using a domain user we created previously (simulating a worker):
<img src="/screenshots/67.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
For example, let's log into david.martinez, with the default password temp123!
<img src="/screenshots/68.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
Once we log in, it will automatically ask us to renew password:
<img src="/screenshots/68.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<img src="/screenshots/69.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

After waiting for a little bit for Windows to configure the system, we will have access to the account:
<img src="/screenshots/70.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<img src="/screenshots/71.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

<br></br>

---
## 📁 10. Shared Resources
---
- [ ] Create folders
- [ ] Configure NTFS permissions
- [ ] Assign permissions by group
- [ ] Validate access

---  

Let's create the folder structure in the domain controller, the folder will be **C:\Shares**, and it will have the following structure:
```
C:\Shares
|___________ Administration
|            
|___________ IT
|
|___________ Marketing
|
|___________ Sales
```
<img src="/screenshots/72.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<br>

Now let's create the network share, to do that, right click into ***C:\Shares → Properties → Sharing → Advanced Sharing***
<img src="/screenshots/73.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
Mark the "Share this folder" option, add the name "Shares" and click intro "Permission"
<img src="/screenshots/74.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
For this share, we will give read permissions to **Authenticated Users**:
<img src="/screenshots/75.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

We will also rely on NTFS, for a real security main layer, so let's configure NTFS Permissions, for that, go into ***C:\Shares → Properties → Security***
<img src="/screenshots/76.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

We will click on ***Advanced***, and then to ***Disable inheritance***, this will convert inherited permissions into explicit permissions.
<img src="/screenshots/77.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<img src="/screenshots/78.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

We needed to disable inheritance, since there are groups that we need to delete and we can't since they got permissions inherited, so lets delete the group ***Users*** for that click into Edit:
<img src="/screenshots/76.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<img src="/screenshots/79.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

Now, we will configure EACH subfolder separately, and give them custom permissions depending on the RBAC model presented at the beginning of this project. 
<img src="/screenshots/80.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<img src="/screenshots/81.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<img src="/screenshots/82.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<img src="/screenshots/83.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<br>

Users may be able to access a share but still not modify content if NTFS permissions are misaligned. Because of that, we have to switch the Shares folder Share permission, which is set by default in Read, to Full control for the Authenticated Users: 
<img src="/screenshots/91.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />


For last, we are also gonna enable **Access-Based Enumeration (ABE)**, which is a Windows feature that **hides files and folders from users who do not have explicit NTFS permissions** to access them, ensuring users only see content they are authorized to view.

An example of ABE application, would be showing only the following folders:

|       Worker        |   Department         |            Showing Folder            |
| :-------------: | :-----------------: | :-----------------------------: |
|     David      |        IT          | IT    |
|     Jaime      |        Sales          | Sales    |

To apply ABE, we have to go to ***Server Manager → File and Storage Services → Shares***:
<img src="/screenshots/86.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

And then Right click into our share ***Properties → Settings → Enable access-based enumeration***:
<img src="/screenshots/87.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<img src="/screenshots/88.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<br>

Now it's time to test it. In our client machine, we gonna log in with David (IT guy), and go to ***Open File Explorer → \\\SRV-DC01\Shares***:
<img src="/screenshots/90.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

We have access to the IT folder and we can also create files:
<img src="/screenshots/92.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />



<br></br>

---
## 🛡️ 11. GPO Configuration
---
- [ ] Creation of GPOs per department
- [ ] Apply system restrictions 
- [ ] Link to OUs
- [ ] Force update policy
- [ ] Configure automatic network drive mapping
- [ ] Deploy drives using Group Policy Preferences (GPP)

---  
First of all, we will create the GPOs for every department. To do so: 
***Server Manager → Tools → Group Policy Management → Group Policy Objects → New***
<img src="/screenshots/93.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

Here, we will create:
```
- GPO_Admin
- GPO_IT
- GPO_Sales
- GPO_Marketing
```
<img src="/screenshots/94.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<br>

Now we are gonna link the GPOs we just created to their respective Department's OU. To do so, ***right click into the OU → Link an existing GPO***:
<img src="/screenshots/95.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<br><br>

Now based on the [GPO Checklist](#️-implementation-checklist) given in the Project Overview, we are gonna implement System restrictions.

1. Auditing (Logs):
    We're gonna create an extra GPO (GPO_Auditing) for:
    - auditing
    - security logging
    - firewall rules
    - login tracking
    <br>

    <img src="/screenshots/93.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
    <img src="/screenshots/98.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
    

    It will be linked to all component of the domain, like Computers and OUs, to do so it has to be linked to the domain itself. So right click into ***taicorp.local →  Link an existing GPO → GPO_Auditing***

    Now we apply the auditing logss by using the **Group Policy Management Editor**:
    <img src="/screenshots/99.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

    1.1. Enable security auditing (logs):
        Computer Configuration → Policies → Windows Settings → Security Settings → Advanced Audit Policy Configuration

        Here, we're gonna double click on:
            - Logon / Logoff → 
                · Audit Logon → Success & Failure
                    This audits both successful and failed logon attempts 
                · Audit Logoff → Success & Failure
                    This audits Success events only, since you can't fail log off
            - Account Logon →
                · Audit Credential Validation → Success + Failure
                    This generates audit events when user account logon credentials are submitted.
            - User Account Management
                · Audit User Account Management → Success
                    This will log users created & deleted, password resets & account changes. 
                · Audit Security Group Management → Success
                    This will log users added & removed from groups, group changes.
                · Audit Computer Account Management → Success
                    This will log clients that have joined the domain, computer object changes.
    <br>

2. Administration:
    First open the **Group Policy Management Editor**:
    <img src="/screenshots/96.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

        2.1 Allow access to Control Panel
        No additional policy configuration is required, as access to the Control Panel is permitted by default.

        2.2 Allow software installation
        No software installation restrictions are configured for Administration users.

        2.3 Allow unrestricted use of CMD / PowerShell
        No restrictive policies are applied, allowing standard access to Command Prompt and PowerShell.

        2.4 Allow use of USB
        No USB device restrictions are configured, therefore removable storage devices are allowed by default.

        2.5 Do not apply desktop restrictions
        No desktop restrictions configured, all allowed for Administration users. 


3. IT:
    First open the **Group Policy Management Editor**:
    <img src="/screenshots/97.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

        3.1 Allow full access to administrative tools
        No administrative restrictions are applied to IT users, allowing access to management consoles and administrative utilities.

        3.2 Allow PowerShell and CMD without restrictions
        No restrictions are configured for Command Prompt or PowerShell.

        3.3 Enable security auditing (logs):
        It has been applied before for every computer in GPO_Auditing

        3.4 Allow software installation
        No software installation restrictions are configured for IT users.

        3.5 Allow USB devices
        USB storage devices are permitted by default.

        3.6 Allow execution with administrative privileges
        No desktop restrictions configured, all allowed for Administration users. 

4. Sales:
    First open the **Group Policy Management Editor**:
    <img src="/screenshots/100.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

        4.1 Block Control Panel
        User Configuration → Policies → Administrative Templates → Control Panel → Prohibit access to Control Panel and PC settings

        4.2 Block software installation
        User Configuration → Policies → Administrative Templates → Windows Components → Windows Installer → Windows Installer → Always Install with elevated privileges → Enable

        User Configuration → Policies → Administrative Templates → Windows Components → Windows Installer → Windows Installer → Prevent Removable Media Source for any installation → Enable

        4.3 Restrict CMD / PowerShell (limited use):
        User Configuration → Policies → Administrative Templates → System → Prevent access to the command prompt → enabled

        User Configuration → Policies → Windows Settings → Security Settings → Software Restriction Policies → New Software Restriction Policies → Add Path Rule → C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe and C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe → Set the Security Level to Disallowed.

        User Configuration → Administrative Templates → System → Don't run specified Windows applications: powershell.exe, powershell_ise.exe, and pwsh.exe

        4.4. Allow USB usage
        No USB restrictions are configured.

        4.5. Block system configuration changes
        User Configuration → Policies → Administrative Templates → System → Prevent access to registry editing tools

5. Marketing:
    First open the **Group Policy Management Editor**:
    <img src="/screenshots/101.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

        5.1. Block Control Panel:
         User Configuration → Policies → Administrative Templates → Control Panel → Prohibit access to Control Panel and PC settings

        5.2. Allow specific software (design / browser):
        We are gonna use Software Restriction Policies (SRP) for a controlled workstation environment, which will:
            - Allow browser
            - Allow Paint / Office
            - Block random execution from Downloads/Desktop

        For that, go to: 
        User Configuration → Policies → Windows Settings → Security Settings → Software Restriction Policies → New Software Restriction Policies → Aditional Rules → New Path Rule:
            - C:\Users\*\Downloads\*.exe
            - C:\Users\*\Downloads\*.msi
            - C:\Users\*\Downloads\*.bat
            - C:\Users\*\Downloads\*.cmd
            - C:\Users\*\Downloads\*.ps1
            - C:\Users\*\Downloads\*.vbs
            - C:\Users\*\Desktop\*.exe
            - C:\Users\*\Desktop\*.msi
            - C:\Users\*\Desktop\*.bat
            - C:\Users\*\Desktop\*.cmd
            - C:\Users\*\Desktop\*.ps1
            - C:\Users\*\Desktop\*.vbs
        
        This will not block the execution of direct access software stored in the directories.

        5.3. Restrict CMD / PowerShell:
        User Configuration → Policies → Administrative Templates → System → Prevent access to the command prompt → enabled

        User Configuration → Policies → Windows Settings → Security Settings → Software Restriction Policies → New Software Restriction Policies → Add Path Rule → C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe and C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe → Set the Security Level to Disallowed.

        User Configuration → Administrative Templates → System → Don't run specified Windows applications: powershell.exe, powershell_ise.exe, and pwsh.exe

        5.4. Allow USB usage:
        No USB restrictions are configured.

        5.5. Block network and system changes:
        We are gonna apply restrictions similar to the Sales department:

            - Block registry tools:
              User Configuration → Policies → Administrative Templates → System → Prevent access to registry editing tools

            - Restrict Control Panel (already applied at 5.1)

            - Prevent unauthorized system modifications:
                · Block software installation:
                    User Configuration → Policies → Administrative Templates → Windows Components → Windows Installer → Windows Installer → Always Install with elevated privileges → Enable

                    User Configuration → Policies → Administrative Templates → Windows Components → Windows Installer → Windows Installer → Prevent Removable Media Source for any installation → Enable

                · Hide network settings:
                    User Configuration → Policies → Administrative Templates → Network → Network Connections → Prohibit access to properties of a LAN connection

Finally, we're gonna execute the following command in a powershell, to apply all GPO changes immediately: **gpupdate /force**



<br></br>

---
## 🔍 12. Testing Scenarios
---
- [ ] Verification of shares access
- [ ] Verification of GPOs application
- [ ] Sales users cannot access IT shared folder ❌  
- [ ] Marketing users are blocked from Control Panel ✔️  
- [ ] DHCP assigns IP addresses automatically ✔️  
- [ ] DNS resolves internal hostnames correctly ✔️  
- [ ] GPOs are applied according to OU structure ✔️  
---
Finally the project is finished, but before leaving, we are gonna make sure all the configuration works.  


First of all, we are gonna make sure that the DNS and DHCP resolutions are being resolved in the client, and also that the client is inside the correct OU.

1. David is really inside the domain:    
<img src="/screenshots/102.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
<img src="/screenshots/103.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />


2. DNS server is correct:
<img src="/screenshots/104.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

3. David is inside the correct OU (IT):
<img src="/screenshots/105.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

<br><br>


Now we're gonna make sure that each department is getting the permissions and blocks correctly by the custom GPOs:

#### IT
- Can access the CMD:
<img src="/screenshots/105.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
- Can access the control panel:
<img src="/screenshots/107.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
- Can check logs using eventviewer:
<img src="/screenshots/108.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
    For example, if we log off David's account:
    <img src="/screenshots/109.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />



#### Sales
We will use Jaime Ortiz's account:
<img src="/screenshots/111.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

- Control panel is blocked:
<img src="/screenshots/110.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
- Can't access the CMD:
<img src="/screenshots/112.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
- Can access system configuration changes (registry editor):
<img src="/screenshots/113.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />


#### Marketing
We will use Lucia Pastor's account:
<img src="/screenshots/114.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />

- Control panel is blocked:
<img src="/screenshots/110.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
- Specific basic software is allow:
<img src="/screenshots/115.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
- Can't access the CMD:
<img src="/screenshots/112.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
- Block network and system changes:
    - Regedit:
    <img src="/screenshots/113.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
    - Prohibit access to properties of a LAN connection (doesn't open):
    <img src="/screenshots/116.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />




#### Administration
We will use Taimour's account:
<img src="/screenshots/117.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
    - Control panel is allowed:
    <img src="/screenshots/107.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />
    - Allow unrestricted use of CMD / PowerShell:
    <img src="/screenshots/118.png" alt="ERROR LOADING IMAGE" style="display: block; margin-left: auto; margin-right: auto;" />


<br><br><br><br>

The project has been finished with the objectives completed.

---
<br>


## 🧠 Skills Demonstrated

- Active Directory administration (AD)  
- Group Policy management (GPO)  
- Windows Server deployment  
- DNS & DHCP configuration  
- Access control & permissions (RBAC, NTFS, Access-Based Enumeration (ABE))  
- SMB Shares
- Network drive deployment with Group Policy Preferences (GPP)
- Troubleshooting enterprise environments  


## ⚠️ Challenges Encountered
- During the installation of the OS in the Windows 11 client, the virtual wizard needed internet connection for the configuration.
- Windows Firewall blocking ICMP packets between VMs (no connectivity) 
- DNS misconfiguration preventing domain join  
- Server hostname not configured as SRV-DC01 
- After changing hostname to SRV-DC01, and trying to log in, it kept giving an error: The security database on the server does not have a computer account for this workstation trust relationship. It couldn't be fixed, provoking a server recreation, since we didn't have a snapshot.
- Forgetting to apply Default Gateway in the DHCP server.
- Even after applying ABE, the users could access other department shares. This was caused by giving permission to all authenticated users to the Shares folder, resulting in giving all the subfolders too. 
- Users allowed to read files in the shares, but not able to write or create files.
- GPO not applying due to incorrect OU linking  
- Permission conflicts between NTFS and Share levels  

## ✅ Results
The environment was successfully deployed and validated.  
All services (AD DS, DNS, DHCP) are fully operational and integrated.  

Security policies and access controls behave as expected across all departments.

## 📄 License
This project is for educational purposes.  
You are free to use, modify, and distribute it.
