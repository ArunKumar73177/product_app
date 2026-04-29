import java.util.*;
import java.util.Arrays;

public class JavaSolutions {

    // ✅ Q1: Two Sum (O(n))
    public static int[] twoSum(int[] nums, int target) {
        Map<Integer, Integer> map = new HashMap<>();

        for (int i = 0; i < nums.length; i++) {
            int complement = target - nums[i];

            if (map.containsKey(complement)) {
                return new int[]{map.get(complement), i};
            }
            map.put(nums[i], i);
        }
        return new int[]{};
    }

    // ✅ Q2: Longest Substring Without Repeating Characters
    public static int longestSubstring(String s) {
        Set<Character> set = new HashSet<>();
        int left = 0, maxLength = 0;

        for (int right = 0; right < s.length(); right++) {
            while (set.contains(s.charAt(right))) {
                set.remove(s.charAt(left));
                left++;
            }
            set.add(s.charAt(right));
            maxLength = Math.max(maxLength, right - left + 1);
        }

        return maxLength;
    }

    // ✅ Q4: Reverse String
    public static String reverseString(String input) {
        char[] arr = input.toCharArray();
        int left = 0, right = arr.length - 1;

        while (left < right) {
            char temp = arr[left];
            arr[left] = arr[right];
            arr[right] = temp;
            left++;
            right--;
        }

        return new String(arr);
    }

    // ✅ Q5: Find duplicates
    public static List<Integer> findDuplicates(int[] nums) {
        Set<Integer> seen = new HashSet<>();
        List<Integer> result = new ArrayList<>();

        for (int num : nums) {
            if (!seen.add(num) && !result.contains(num)) {
                result.add(num);
            }
        }

        return result;
    }

    public static void main(String[] args) {

        // Q1
        System.out.println(Arrays.toString(twoSum(new int[]{2,7,11,15}, 9)));

        // Q2
        System.out.println(longestSubstring("abcabcbb"));

        // Q4
        System.out.println(reverseString("hello"));

        // Q5
        System.out.println(findDuplicates(new int[]{1,2,3,2,4,3}));
    }
}