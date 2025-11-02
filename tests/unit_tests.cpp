
#include <gtest/gtest.h>
#include <climits>
#include "../math_operations.h"

TEST(AdditionTests, PositiveNumbers) {
	EXPECT_EQ(add(2, 3), 5);
	EXPECT_EQ(add(40, 60), 100);
}

TEST(AdditionTests, ZeroValues) {
	EXPECT_EQ(add(7, 0), 7);
	EXPECT_EQ(add(0, 0), 0);
}

TEST(AdditionTests, NegativeNumbers) {
	EXPECT_EQ(add(-2, -3), -5);
	EXPECT_EQ(add(4, -3), 1);
}

TEST(AdditionTests, BoundaryValues) {
	EXPECT_EQ(add(INT_MAX - 1, 1), INT_MAX);
	EXPECT_EQ(add(INT_MIN + 1, -1), INT_MIN);
}

int main(int argc, char **argv) {
	::testing::InitGoogleTest(&argc, argv);
	return RUN_ALL_TESTS();
}
