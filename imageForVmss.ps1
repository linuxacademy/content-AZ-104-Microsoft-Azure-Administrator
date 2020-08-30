$scaleSetName = "labVMSS1"

$subnet = New-AzVirtualNetworkSubnetConfig -Name "defaultSubnet" -AddressPrefix 10.0.0.0/24

$vnet = New-AzVirtualNetwork -ResourceGroupName $rg -Name "labVnet1" -Location $location -AddressPrefix 10.0.0.0/16 -Subnet $subnet

$publicIP = New-AzPublicIpAddress -ResourceGroupName $rg -Location $location -AllocationMethod Static -Name "labPubIp"

$frontendIP = New-AzLoadBalancerFrontendIpConfig -Name "fePool" -PublicIpAddress $publicIP

$backendPool = New-AzLoadBalancerBackendAddressPoolConfig -Name "bePool"

$inboundNATPool = New-AzLoadBalancerInboundNatPoolConfig -Name "RDPRule1" -FrontendIpConfigurationId $frontendIP.Id -Protocol TCP -FrontendPortRangeStart 50001 -FrontendPortRangeEnd 50010 -BackendPort 3389

$lb = New-AzLoadBalancer -ResourceGroupName $rg -Name "myLoadBalancer" -Location $location -FrontendIpConfiguration $frontendIP -BackendAddressPool $backendPool -InboundNatPool $inboundNATPool

Add-AzLoadBalancerProbeConfig -Name "lbHealthProbe" -LoadBalancer $lb -Protocol TCP -Port 80 -IntervalInSeconds 15 -ProbeCount 2

Add-AzLoadBalancerRuleConfig -Name "lbRule" -LoadBalancer $lb -FrontendIpConfiguration $lb.FrontendIpConfigurations[0] -BackendAddressPool $lb.BackendAddressPools[0] -Protocol TCP -FrontendPort 80 -BackendPort 80 -Probe (Get-AzLoadBalancerProbeConfig -Name "lbHealthProbe" -LoadBalancer $lb)

Set-AzLoadBalancer -LoadBalancer $lb

$ipConfig = New-AzVmssIpConfig -Name "vmssIpConfig" -LoadBalancerBackendAddressPoolsId $lb.BackendAddressPools[0].Id -LoadBalancerInboundNatPoolsId $inboundNATPool.Id -SubnetId $vnet.Subnets[0].Id

$vmssConfig = New-AzVmssConfig -Location $location -SkuCapacity 2 -SkuName "Standard_B2s" -UpgradePolicyMode "Automatic"

Set-AzVmssStorageProfile $vmssConfig -OsDiskCreateOption "FromImage" -ImageReferenceId $galleryImage.Id

Add-AzVmssNetworkInterfaceConfiguration -VirtualMachineScaleSet $vmssConfig -Name "network-config" -Primary $true -IPConfiguration $ipConfig

New-AzVmss -ResourceGroupName $rg -Name $scaleSetName -VirtualMachineScaleSet $vmssConfig
