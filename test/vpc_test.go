// example test from https://terratest.gruntwork.io/docs/getting-started/quick-start/
package test

import (
	"context"
	"fmt"
	"github.com/aws/aws-sdk-go-v2/service/ec2/types"
	"log"
	"os"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Required module author inputs are testPath and testRegions, testCases are optional
var testPath = "../modules/vpc/examples/minimal"

var testRegions = []struct {
	region  string
	profile string
}{
	{
		region:  "us-west-2",
		profile: "default",
	},
}

var testCases = []struct {
	name     string
	function func(*testing.T, *terraform.Options)
}{
	{
		name:     "validate subnets created are as expected",
		function: validateSubnets,
	},
	{
		name:     "validates route tables are using the correct NAT Gateways",
		function: validateNatGatewayAzAffinity,
	},
}

// a test case that verifies that the subnets created are as expected
func validateSubnets(t *testing.T, tfOpts *terraform.Options) {
	publicSubnetIds := terraform.OutputList(t, tfOpts, "public_subnet_ids")
	privateSubnetAIds := terraform.OutputList(t, tfOpts, "private_subnet_a_ids")
	privateSubnetBIds := terraform.OutputList(t, tfOpts, "private_subnet_b_ids")

	assert.Equal(t, 3, len(publicSubnetIds), "minimal example should produce 3 public subnets")
	assert.Equal(t, 3, len(privateSubnetAIds), "minimal example should produce 3 private_a subnets")
	assert.Equal(t, 0, len(privateSubnetBIds), "minimal example should produce 0 private_b subnets")
	for _, subnet := range publicSubnetIds {
		assert.NotContains(t, privateSubnetAIds, subnet, "subnets in public should not also be in private")
	}
	for _, subnet := range privateSubnetAIds {
		assert.NotContains(t, publicSubnetIds, subnet, "subnets in public should not also be in private")
	}
}

// a test that validates that route tables are pointing to nat gateways in the same az as the subnet
func validateNatGatewayAzAffinity(t *testing.T, tfOpts *terraform.Options) {
	region := tfOpts.Vars["region"].(string)
	profile := tfOpts.Vars["profile"].(string)
	client := getEc2Client(profile, region)
	subnetIds := terraform.OutputList(t, tfOpts, "private_subnet_a_ids")
	subnets, err := client.DescribeSubnets(context.TODO(), &ec2.DescribeSubnetsInput{SubnetIds: subnetIds})
	if err != nil {
		t.Errorf("failed to query ec2 api. Error: %s", err.Error())
		return
	}
	for _, subnet := range subnets.Subnets {
		gwAz, err := getNatGatewayAz(client, subnet.SubnetId)
		if err != nil {
			t.Errorf("cannot find az for the nat gateway associated with subnet %s. Error: %s", *subnet.SubnetId, err.Error())
			continue
		}
		assert.Equal(
			t,
			*subnet.AvailabilityZone,
			*gwAz,
			fmt.Sprintf("NAT Gateway for %s is not in the same az", *subnet.SubnetId),
		)
	}
}

func getNatGatewayAz(client *ec2.Client, subnet *string) (*string, error) {
	routeTableResponse, err := client.DescribeRouteTables(
		context.TODO(),
		&ec2.DescribeRouteTablesInput{
			Filters: []types.Filter{
				{
					Name:   aws.String("association.subnet-id"),
					Values: []string{*subnet},
				},
			},
		},
	)
	if err != nil {
		return nil, err
	}
	var natGatewayId *string = nil
	for _, route := range routeTableResponse.RouteTables[0].Routes {
		if route.NatGatewayId != nil {
			natGatewayId = route.NatGatewayId
		}
	}
	if natGatewayId == nil {
		return nil, fmt.Errorf("subnet %s does not have a nat gateway in it's routes", *subnet)
	}
	natGatewaysResponse, err := client.DescribeNatGateways(context.TODO(), &ec2.DescribeNatGatewaysInput{
		NatGatewayIds: []string{*natGatewayId},
	})
	if err != nil {
		return nil, err
	}
	gwSubnetId := natGatewaysResponse.NatGateways[0].SubnetId
	subnets, err := client.DescribeSubnets(context.TODO(), &ec2.DescribeSubnetsInput{SubnetIds: []string{*gwSubnetId}})
	if err != nil {
		return nil, err
	}
	return subnets.Subnets[0].AvailabilityZone, nil
}

// Generic test code to stand up deployments and feed them to any unit tests that have been provided.
// Test authors probably won't need to change anything below this line
func TestMinimal(t *testing.T) {
	t.Parallel()
	for _, testRegion := range testRegions {
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: testPath,
			Vars: map[string]interface{}{
				"region":  testRegion.region,
				"profile": testRegion.profile,
			},
		})
		t.Run(testRegion.region, func(t *testing.T) {
			t.Parallel()
			initAndApply(t, terraformOptions)
			for _, testCase := range testCases {
				t.Run(testCase.name, func(t *testing.T) {
					t.Parallel()
					testCase.function(t, terraformOptions)
				})
			}
		})
	}
}

func initAndApply(t *testing.T, terraformOptions *terraform.Options) {
	if os.Getenv("SKIP_DESTROY") != "1" {
		defer terraform.Destroy(t, terraformOptions)
	}
	terraform.InitAndApply(t, terraformOptions)
}

func getEc2Client(profile string, region string) *ec2.Client {
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithSharedConfigProfile(profile), config.WithRegion(region))
	if err != nil {
		log.Fatalf("failed to load configuration, %v", err)
	}
	cfg.Region = region
	return ec2.NewFromConfig(cfg)
}