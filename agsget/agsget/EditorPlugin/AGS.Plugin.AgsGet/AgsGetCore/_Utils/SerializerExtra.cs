using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

namespace AgsGetCore
{
    public class ShouldSerializeContractResolver : DefaultContractResolver
    {
        public static readonly ShouldSerializeContractResolver Instance = new ShouldSerializeContractResolver();

        protected override JsonProperty CreateProperty(MemberInfo member, MemberSerialization memberSerialization)
        {
            JsonProperty property = base.CreateProperty(member, memberSerialization);

            if (property.PropertyType == typeof(string))
            {
                // Do not include emptry strings
                property.ShouldSerialize = instance =>
                {
                    return !string.IsNullOrWhiteSpace(instance.GetType().GetProperty(member.Name).GetValue(instance, null) as string);
                };
            }
            else if (property.PropertyType == typeof(DateTime))
            {
                // Do not include zero DateTime
                property.ShouldSerialize = instance =>
                {
                    return Convert.ToDateTime(instance.GetType().GetProperty(member.Name).GetValue(instance, null)) != default(DateTime);
                };
            }
            return property;
        }
    }

    class SerializerExtra
    {
        public static string ObjectToJSON(object value)
        {
            return JsonConvert.SerializeObject(value,
                Formatting.Indented,
                new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore,
                    ContractResolver = ShouldSerializeContractResolver.Instance
                });
        }
    }
}
